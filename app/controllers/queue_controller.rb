class QueueController < ApplicationController
  def upload
    put "PARAMS: #{ params.inspect }"
    render json: { files: [ { title: "Pressure Drop", artist: "Toots and the Maytails" }, { title: "Big Guns Down", artist: "Easy Big Fella" } ] }
  end
end
