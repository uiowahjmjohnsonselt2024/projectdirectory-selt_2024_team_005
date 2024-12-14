class SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  # Show the login form
  def new
  end

  # Handle the login process
  def create
    # Find the user by username
    @user = User.find_by(username: params[:username])

    # Check if user exists and password is correct
    if @user && @user.authenticate(params[:password])
      # Set up session with username instead of id
      session[:username] = @user.username  # Save username in session
      flash[:notice] = "Successfully logged in!"
      redirect_to user_path(@user.username)  # Redirect to home page
    elsif !(@user && @user.authenticate(params[:password]))
      flash.now[:alert] = "Invalid username or password"
      render :new  # Render the login form again
    else
      flash[:notice] = "Unexpected error occurred"
    end
  end

  # Handle the logout process
  def destroy
    session[:username] = nil  # Clear the username from session
    redirect_to login_path, notice: "You have been logged out."
  end
end
