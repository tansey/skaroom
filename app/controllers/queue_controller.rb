class QueueController < ApplicationController
  def upload
    puts "PARAMS: #{ params[ :upload_music ].content_type.inspect }"
    # song = Song.new params[ :upload_music ]
    render json: { files: [ { title: "Pressure Drop", artist: "Toots and the Maytails" }, { title: "Big Guns Down", artist: "Easy Big Fella" } ] }
  end
end
