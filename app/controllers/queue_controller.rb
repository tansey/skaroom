class QueueController < ApplicationController
  def upload
    render json: { files: [ { name: "Testing 1" }, { name: "Testing 2" } ] }
  end
end
