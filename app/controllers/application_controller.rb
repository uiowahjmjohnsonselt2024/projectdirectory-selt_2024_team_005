class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.

  helper_method :current_user

  def current_user
    puts session[:username]
    @current_user ||= User.find_by(username: session[:username]) if session[:username]
  end
  allow_browser versions: :modern
end
