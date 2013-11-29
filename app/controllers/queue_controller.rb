class QueueController < ApplicationController
  def upload
    render json: { success: true }
  end
end
