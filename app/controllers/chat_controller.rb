class ChatController < WebsocketRails::BaseController

  before_filter :online_rudies
  before_filter :online_djs
  before_filter :stats_for_spin
  before_filter :current_dj
  before_filter :current_song
  before_filter :init_timer
  # before_filter :current_song

  def connect
    send_message "who_is_connected", { rudies: @@rudies, djs: @@djs }
    puts "DJs: #{ @@djs }"
    @@rudies << current_rudy unless @@rudies.include? current_rudy or not rudy_signed_in?
    broadcast_message( "connected", { rudy: current_rudy } ) if rudy_signed_in?
    send_message "me", { rudy: current_rudy }
    broadcast_message( "walt.welcome", { rudy: current_rudy } ) if rudy_signed_in?

    #puts "SONG: #{ @@song.inspect }"
    if @@song.nil?
      Thread.new kickstart_radio
    else
      send_message "new_song", {  dj:     @@djs[ @@dj_index ],
                                  song: { id:       @@song.id, 
                                          title:    @@song.title, 
                                          artist:   @@song.artist, 
                                          song:     @@song.song.to_s, 
                                          duration: @@song.duration, 
                                          position: ( Time.now - @@started ).round,
                                          rudy:     @@song.rudy.name } }, namespace: :music
    end
  end

  def disconnect
    unless current_rudy.nil?
      @@rudies.delete current_rudy
      @@djs.delete current_rudy
      broadcast_message "disconnected", { rudy: current_rudy }
      kickstart_radio if current_rudy.id == @@dj.id
    else
      # Validate connections, djs, rudies, etc.
    end
  end

  def toast
    broadcast_message "new_toast", { rudy: current_rudy.name, toast: message[ :message ] }, namespace: :chat
  end

  def add_dj
    unless current_rudy.songs.empty?
      @@djs << current_rudy
      broadcast_message "dj_added", { rudy: current_rudy }
      kickstart_radio if @@djs.count == 1
    else
      send_message "dj_not_added", {}
    end
  end

  def remove_dj
    @@djs.delete current_rudy
    broadcast_message "dj_removed", { rudy: current_rudy }
    kickstart_radio if current_rudy.id == @@dj.id
  end

  def lame
    unless @@dj == current_rudy
      @@spin_stats[ :awesome ].delete current_rudy
      @@spin_stats[ :meh     ].delete current_rudy
      @@spin_stats[ :lame    ] << current_rudy unless @@spin_stats[ :lame ].include? current_rudy
      broadcast_message "dj_lamed", { rudy: current_rudy, awesomes: @@spin_stats[ :awesome ].count, mehs: @@spin_stats[ :meh ].count, lames: @@spin_stats[ :lame ].count }
    end
  end

  def meh
    unless @@dj == current_rudy
      @@spin_stats[ :awesome ].delete current_rudy
      @@spin_stats[ :meh     ] << current_rudy unless @@spin_stats[ :meh ].include? current_rudy
      @@spin_stats[ :lame    ].delete current_rudy
      broadcast_message "dj_mehed", { rudy: current_rudy, awesomes: @@spin_stats[ :awesome ].count, mehs: @@spin_stats[ :meh ].count, lames: @@spin_stats[ :lame ].count }
    end
  end

  def awesome
    unless @@dj == current_rudy
      @@spin_stats[ :awesome ] << current_rudy unless @@spin_stats[ :awesome ].include? current_rudy
      @@spin_stats[ :meh     ].delete current_rudy
      @@spin_stats[ :lame    ].delete current_rudy
      broadcast_message "dj_awesomed", { rudy: current_rudy, awesomes: @@spin_stats[ :awesome ].count, mehs: @@spin_stats[ :meh ].count, lames: @@spin_stats[ :lame ].count }
    end
  end

  def query
    songs = Song.where( "title like '%#{ message[ :search_term ] }%' or artist like '%#{ message[ :search_term ] }%'" ).limit( 40 ).to_a
    puts "SONGS: #{ songs.inspect }"
    send_message "search_results", { songs: songs }
  end

  def add_song_to_queue
    song = Song.find( message[ :id ] )
    if QueuedSong.where( rudy_id: current_rudy.id, song_id: song.id ).first.nil?
      queued_song = QueuedSong.create rudy_id: current_rudy.id, song_id: song.id, sequence: current_rudy.queued_songs.count
      # send_message "song_added_to_queue", { queued_song_id: queued_song.id, song: song }
      send_message( "new_queue", queue: current_rudy.queued_songs.order( :sequence ).as_json( include: :song ) )
    end
  end

  def remove_song_from_queue
    queued_song = QueuedSong.find( message[ :id ] )
    unless queued_song.nil?
      #send_message "song_removed_from_queue", { queued_song_id: queued_song.id, song: queued_song.song }
      queued_song.delete
      current_rudy.queued_songs.order( :sequence ).each_with_index do |queued_song, index|
        queued_song.sequence = index
        queued_song.save
      end
      send_message( "new_queue", queue: current_rudy.queued_songs.order( :sequence ).as_json( include: :song ) )
    end
  end

  def move_up
    song_to_move     = current_rudy.queued_songs.find message[ :id ]
    unless song_to_move.sequence == 0
      song_to_displace = current_rudy.queued_songs.where( sequence: song_to_move.sequence - 1 ).first

      song_to_move.sequence     = song_to_move.sequence - 1
      song_to_displace.sequence = song_to_displace.sequence + 1

      song_to_move.save
      song_to_displace.save

      send_message( "new_queue", queue: current_rudy.queued_songs.order( :sequence ).as_json( include: :song ) )
    end
  end

  def move_down
    song_to_move     = current_rudy.queued_songs.find message[ :id ]
    unless song_to_move.sequence == current_rudy.queued_songs.count
      song_to_displace = current_rudy.queued_songs.where( sequence: song_to_move.sequence + 1 ).first

      song_to_move.sequence     = song_to_move.sequence + 1
      song_to_displace.sequence = song_to_displace.sequence - 1

      song_to_move.save
      song_to_displace.save
      
      send_message( "new_queue", queue: current_rudy.queued_songs.order( :sequence ).as_json( include: :song ) )
    end
  end

  private

  def online_rudies
    @@rudies ||= []
  end

  def online_djs
    @@djs ||= []
  end

  def stats_for_spin
    @@spin_stats ||= { awesome: [], meh: [], lame: [] }
  end

  def current_song
    @@song ||= nil
  end

  def current_dj
    @@dj ||= nil
    @@dj_index ||= nil
  end

  def init_timer
    @@current_timer ||= nil
  end

  def kickstart_radio

    EM.cancel_timer( @@current_timer )

    unless @@dj.nil?
      @@dj.points += @@spin_stats[ :meh ].count + @@spin_stats[ :awesome ].count
      @@dj.save

      if current_rudy.id == @@dj.id
        send_message( "new_queue", queue: current_rudy.queued_songs.order( :sequence ).as_json( include: :song ) )
      end
    end
    unless @@song.nil?
      @@song.points += @@spin_stats[ :awesome ].count - @@spin_stats[ :lame ].count
      @@song.save
    end

    if @@djs.empty?
      @@song  = Song.all.sample
      @@dj      = nil
      @@dj_index = nil
    else
      if @@dj.nil?
        @@dj_index = 0
      else
        @@dj_index += 1
        @@dj_index = 0 if @@dj_index >= @@djs.count
      end
      @@dj    = @@djs[ @@dj_index ]
      @@song  = @@dj.songs.first
      reorder_queued_songs if @@dj.id == current_rudy.id
    end

    @@started   = Time.now

    @@spin_stats = { awesome: [], meh: [], lame: [] }

    puts "CURRENT DJ: #{ @@dj.inspect }"

    unless @@rudies.nil?
      broadcast_message "new_song", { dj:   @@dj,
                                      song: { id:       @@song.id, 
                                              title:    @@song.title, 
                                              artist:   @@song.artist, 
                                              song:     @@song.song.to_s, 
                                              duration: @@song.duration, 
                                              position: 0,
                                              rudy:     @@song.rudy.name } }, namespace: :music
    end

    @@current_timer = EM.add_timer( @@song.duration ) { kickstart_radio }
  end

  def reorder_queued_songs
    first_queued_song = current_rudy.queued_songs.order( :sequence ).first
    first_queued_song.sequence = current_rudy.queued_songs.count + 1
    first_queued_song.save
    current_rudy.queued_songs.order( :sequence ).each_with_index do |queued_song, index|
      queued_song.sequence = index
      queued_song.save
    end
  end
end
