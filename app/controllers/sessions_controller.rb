class SessionsController < ApplicationController
  def create
    # Find the user by username
    @user = User.find_by(username: params[:username])

    # Check if user exists and password is correct
    if @user && @user.authenticate(params[:password])
      # Set up session with username instead of id
      session[:username] = @user.username  # Save username in session
      flash[:notice] = "Successfully logged in!"
      redirect_to home_path
    else
      flash.now[:alert] = "Invalid username or password"
      render :new
    end
  end

  def destroy
    session[:username] = nil  # Clear the username from session
    redirect_to login_path, notice: "You have been logged out."
  end
end
