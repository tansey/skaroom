WebsocketRails::EventMap.describe do
  # The :client_connected method is fired automatically when a new client connects
  subscribe :client_connected, :to => ChatController, :with_method => :connect
  # The :client_disconnected method is fired automatically when a client disconnects
  subscribe :client_disconnected, :to => ChatController, :with_method => :disconnect

  namespace :chat do
    subscribe :message, 'chat#toast'
  end
  namespace :dj do
    subscribe :add,     'chat#add_dj'
    subscribe :remove,  'chat#remove_dj'
    subscribe :lame,    'chat#lame'
    subscribe :meh,     'chat#meh'
    subscribe :awesome, 'chat#awesome'
  end
  namespace :playlist do
    subscribe :add,     'chat#add_song_to_queue'
    subscribe :remove,  'chat#remove_song_from_queue'
    subscribe :query,   'chat#query'
  end

  # You can use this file to map incoming events to controller actions.
  # One event can be mapped to any number of controller actions. The
  # actions will be executed in the order they were subscribed.
  #
  # Uncomment and edit the next line to handle the client connected event:
  #   subscribe :client_connected, :to => Controller, :with_method => :method_name
  #
  # Here is an example of mapping namespaced events:
  #   namespace :product do
  #     subscribe :new, :to => ProductController, :with_method => :new_product
  #   end
  # The above will handle an event triggered on the client like `product.new`.
end
