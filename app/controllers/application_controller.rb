class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :authenticate_user!  # Ensure authentication by default for all controllers

  private

  def authenticate_user!
    unless user_signed_in?
      # flash[:alert] = "You need to log in to access this page."
      redirect_to root_path  # Replace `login_path` with your actual login route
    end
  end

  def user_signed_in?
    current_user.present?
  end

  helper_method :current_user
  def current_user
    puts session[:username]
    @current_user ||= User.find_by(username: session[:username]) if session[:username]
  end
  allow_browser versions: :modern
end
