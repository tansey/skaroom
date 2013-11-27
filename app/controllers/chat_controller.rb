class ChatController < WebsocketRails::BaseController

  before_filter :online_rudies

  def connect
    send_message "who_is_connected", { rudies: @@rudies }
    @@rudies << current_rudy
    broadcast_message "connected", { rudy: current_rudy }
    broadcast_message "walt.welcome", { rudy: current_rudy }
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
end
