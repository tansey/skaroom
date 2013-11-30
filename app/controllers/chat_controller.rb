class ChatController < WebsocketRails::BaseController

  before_filter :online_rudies
  before_filter :current_song

  def connect
    send_message "who_is_connected", { rudies: @@rudies }
    @@rudies << current_rudy # unless @@rudies.include? current_rudy
    puts "RUDIES: #{ @@rudies.inspect }"
    broadcast_message "connected", { rudy: current_rudy }
    broadcast_message "walt.welcome", { rudy: current_rudy }

    puts "SONG: #{ @@song.inspect }"
    send_message "music.playing", { song: { id:       @@song.id, 
                                            title:    @@song.title, 
                                            artist:   @@song.artist, 
                                            song:     @@song.song.to_s, 
                                            duration: @@song.duration, 
                                            position: @@position,
                                            rudy:     @@song.rudy.name } }
  end

  def disconnect
    @@rudies.delete current_rudy
    broadcast_message "disconnected", { rudy: current_rudy }
  end

  def toast
    broadcast_message "new_toast", { rudy: current_rudy.name, toast: message[ :message ] }, namespace: :chat
  end

  private

  def online_rudies
    @@rudies ||= []
  end

  def current_song
    if @@song.nil?
      @@song      = Song.all.sample
      @@position  = @@song.duration
      @@started   = Time.now
      #while true
      #  handle_song( @@song )
      #  sleep 1
      #end
    end
  end

  def handle_song( song )
    @@position -= 1
    puts "POSITION: #{ @@position }"
    if @@position <= 0
      @@song = Song.all.sample
      unless @@song.nil?
        @@position = @@song.duration
        puts "NEW SONG: #{ @@song.inspect }"

        broadcast_message "music.playing", { song: {  id:       @@song.id, 
                                                      title:    @@song.title, 
                                                      artist:   @@song.artist, 
                                                      song:     @@song.song.to_s, 
                                                      duration: @@song.duration, 
                                                      position: @@position,
                                                      rudy:     @@song.rudy.name } }
      end
    end
  end
end
