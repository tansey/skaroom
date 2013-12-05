class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for( :sign_up ) do |u|
      u.permit :email, :password, :password_confirmation, :current_password, :remember_me,
               :name, :location, :gender, :birthdate, # :terms_of_service,
               :points, :actual_name, :nickname
    end
    devise_parameter_sanitizer.for( :sign_in ) do |u|
      u.permit :email, :password
    end
    devise_parameter_sanitizer.for( :account_update ) do |u|
      u.permit :email, :password, :password_confirmation, :current_password, :remember_me,
               :name, :location, :gender, :birthdate, # :terms_of_service,
               :points, :actual_name, :nickname
    end
  end

  private

  def is_rudy_signed_in
    unless rudy_signed_in?
      flash[ :error ] = "Please sign in."
      redirect_to new_rudy_session_path
    end
  end
end
