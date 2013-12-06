class ChatController < WebsocketRails::BaseController

  before_filter :online_rudies
  before_filter :online_djs
  before_filter :current_song
  # before_filter :current_song

  def connect
    send_message "who_is_connected", { rudies: @@rudies, djs: @@djs }
    puts "DJs: #{ @@djs }"
    @@rudies << current_rudy unless @@rudies.include? current_rudy or not rudy_signed_in?
    broadcast_message( "connected", { rudy: current_rudy } ) if rudy_signed_in?
    broadcast_message( "walt.welcome", { rudy: current_rudy } ) if rudy_signed_in?

    #puts "SONG: #{ @@song.inspect }"
    if @@song.nil?
      Thread.new kickstart_radio
    else
      send_message "new_song", {  dj:   @@djs[ 0 ],
                                  song: {  id:       @@song.id, 
                                          title:    @@song.title, 
                                          artist:   @@song.artist, 
                                          song:     @@song.song.to_s, 
                                          duration: @@song.duration, 
                                          position: ( Time.now - @@started ).round,
                                          rudy:     @@song.rudy.name } }, namespace: :music
    end
  end

  def disconnect
    @@rudies.delete current_rudy
    @@djs.delete current_rudy
    broadcast_message "disconnected", { rudy: current_rudy }
  end

  def toast
    broadcast_message "new_toast", { rudy: current_rudy.name, toast: message[ :message ] }, namespace: :chat
  end

  def add_dj
    unless current_rudy.songs.empty?
      @@djs << current_rudy
      broadcast_message "dj_added", { rudy: current_rudy }
    else
      send_message "dj_not_added", {}
    end
  end

  def remove_dj
    @@djs.delete current_rudy
    broadcast_message "dj_removed", { rudy: current_rudy }
  end

  def lame
    broadcast_message "dj_lamed", { rudy: current_rudy }
  end

  def meh
    broadcast_message "dj_mehed", { rudy: current_rudy }
  end

  def awesome
    broadcast_message "dj_awesomed", { rudy: current_rudy }
  end

  def query
    songs = Song.where( "title like '%#{ message[ :search_term ] }%' or artist like '%#{ message[ :search_term ] }%'" ).limit( 40 ).to_a
    puts "SONGS: #{ songs.inspect }"
    send_message "search_results", { songs: songs }
  end

  def add_song_to_queue
    song = Song.find( message[ :id ] )
    puts "SONG: #{ song.inspect }"
    if QueuedSong.where( rudy_id: current_rudy.id, song_id: song.id ).first.nil?
      queued_song = QueuedSong.create rudy_id: current_rudy.id, song_id: song.id, sequence: current_rudy.queued_songs.count
      send_message "song_added_to_queue", { queued_song_id: queued_song.id, song: song }
    end
  end

  def remove_song_from_queue
    queued_song = QueuedSong.find( message[ :id ] )
    puts "SONG: #{ queued_song.inspect }"
    unless queued_song.nil?
      send_message "song_removed_from_queue", { queued_song_id: queued_song.id, song: queued_song.song }
      queued_song.delete
      current_rudy.queued_songs.order( :sequence ).each_with_index do |queued_song, index|
        queued_song.sequence = index
        queued_song.save
      end
    end
  end

  private

  def online_rudies
    @@rudies ||= []
  end

  def online_djs
    @@djs ||= []
  end

  def current_song
    @@song ||= nil
  end

  def kickstart_radio
    if @@djs.empty?
      @@song  = Song.all.sample
      dj      = nil
    else
      dj      = @@djs.shift
      @@song  = dj.songs.first
      reorder_queued_songs if dj == current_rudy
      @@djs.push dj
    end
    @@started   = Time.now

    puts "SONG: #{ @@song.inspect }"
    puts "DJ:   #{ dj.inspect }"

    unless @@rudies.nil?
      broadcast_message "new_song", { dj:   dj,
                                      song: { id:       @@song.id, 
                                              title:    @@song.title, 
                                              artist:   @@song.artist, 
                                              song:     @@song.song.to_s, 
                                              duration: @@song.duration, 
                                              position: 0,
                                              rudy:     @@song.rudy.name } }, namespace: :music
    end

    EM.add_timer( @@song.duration ) { kickstart_radio }
  end

  def reorder_queued_songs
    puts "SONGS BEFORE REORDER: #{ current_rudy.queued_songs.inspect }"
    first_queued_song = current_rudy.queued_songs.order( :sequence ).shift
    current_rudy.queued_songs.order( :sequence ).each_with_index do |queued_song, index|
      queued_song.sequence = index
      queued_song.save
    end
    first_queued_song.sequence = current_rudy.queued_songs.count
    first_queued_song.rudy_id = current_rudy.id
    first_queued_song.save
    puts "SONGS AFTER REORDER: #{ current_rudy.queued_songs.inspect }"
  end
end
