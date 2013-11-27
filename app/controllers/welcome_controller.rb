class WelcomeController < ApplicationController
  def index
    if rudy_signed_in?
      render "dashboard/index"
    else
      render :splash
    end
  end
end
