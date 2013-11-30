class ChatController < WebsocketRails::BaseController

  before_filter :online_rudies
  before_filter :online_djs
  # before_filter :current_song

  def connect
    send_message "who_is_connected", { rudies: @@rudies }
    @@rudies << current_rudy unless @@rudies.include? current_rudy or not rudy_signed_in?
    puts "RUDIES: #{ @@rudies.inspect }"
    broadcast_message( "connected", { rudy: current_rudy } ) if rudy_signed_in?
    broadcast_message( "walt.welcome", { rudy: current_rudy } ) if rudy_signed_in?

    Thread.new kickstart_radio # if @@song.nil?

    #now_playing = current_song
    #puts "SONG: #{ now_playing.inspect }"
    #send_message "music.playing", { song: { id:       now_playing.song.id, 
    #                                        title:    now_playing.song.title, 
    #                                        artist:   now_playing.song.artist, 
    #                                        song:     now_playing.song.song.to_s, 
    #                                        duration: now_playing.song.duration, 
    #                                        position: now_playing.position,
    #                                        rudy:     now_playing.song.rudy.name } }
  end

  def disconnect
    @@rudies.delete current_rudy
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

  def kickstart_radio
    puts "Kickstarting the radio."
    @@song      = Song.all.sample
    @@position  = 0
    @@started   = Time.now

    unless @@rudies.nil?
      broadcast_message "new_song", { song: { id:       @@song.id, 
                                              title:    @@song.title, 
                                              artist:   @@song.artist, 
                                              song:     @@song.song.to_s, 
                                              duration: @@song.duration, 
                                              position: @@position,
                                              rudy:     @@song.rudy.name } }, namespace: :music
    end

    EM.add_timer( 1 ) { @@position -= 1 }
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
