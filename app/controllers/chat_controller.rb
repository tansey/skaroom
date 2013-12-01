class ChatController < WebsocketRails::BaseController

  before_filter :online_rudies
  before_filter :online_djs
  before_filter :current_song
  # before_filter :current_song

  def connect
    send_message "who_is_connected", { rudies: @@rudies }
    @@rudies << current_rudy unless @@rudies.include? current_rudy or not rudy_signed_in?
    puts "RUDIES: #{ @@rudies.inspect }"
    broadcast_message( "connected", { rudy: current_rudy } ) if rudy_signed_in?
    broadcast_message( "walt.welcome", { rudy: current_rudy } ) if rudy_signed_in?

    #puts "SONG: #{ @@song.inspect }"
    if @@song.nil?
      Thread.new kickstart_radio
    else
      puts "Playing a song in progress. SONG: #{ @@song.inspect }, STARTED: #{ @@started }"
      send_message "new_song", { song: {  id:       @@song.id, 
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
    puts "DJ Added"
    @@djs << current_rudy
    broadcast_message "dj_added", { rudy: current_rudy }
  end

  def remove_dj
    puts "DJ Removed"
    @@djs.delete current_rudy
    broadcast_message "dj_removed", { rudy: current_rudy }
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
    puts "Kickstarting the radio."
    @@song      = Song.all.sample
    @@started   = Time.now

    unless @@rudies.nil?
      broadcast_message "new_song", { song: { id:       @@song.id, 
                                              title:    @@song.title, 
                                              artist:   @@song.artist, 
                                              song:     @@song.song.to_s, 
                                              duration: @@song.duration, 
                                              position: 0,
                                              rudy:     @@song.rudy.name } }, namespace: :music
    end

    #EM.add_timer( 1 ) { @@position += 1 }
    EM.add_timer( @@song.duration ) { kickstart_radio }
  end

  #def handle_song( song )
  #  @@position -= 1
  #  puts "POSITION: #{ @@position }"
  #  if @@position <= 0
  #    @@song = Song.all.sample
  #    unless @@song.nil?
  #      @@position = @@song.duration
  #      puts "NEW SONG: #{ @@song.inspect }"

  #      broadcast_message "music.playing", { song: {  id:       @@song.id, 
  #                                                    title:    @@song.title, 
  #                                                    artist:   @@song.artist, 
  #                                                    song:     @@song.song.to_s, 
  #                                                    duration: @@song.duration, 
  #                                                    position: @@position,
  #                                                    rudy:     @@song.rudy.name } }
  #    end
  #  end
  #end
end
