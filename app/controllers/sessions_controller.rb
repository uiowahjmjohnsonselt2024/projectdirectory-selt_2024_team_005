class SessionsController < ApplicationController
  # Show the login form
  def new
  end

  # Handle the login process
  def create
    # Find the user by username
    @user = User.find_by(username: params[:username])

    # Check if user exists and password is correct
    if @user && @user.authenticate(params[:password])
      # Set up session
      session[:user_id] = @user.id  # Save user ID in session to keep user logged in
      flash.now[:notice] = "Successfully logged in!"
      redirect_to home_path  # Redirect to home page
    elsif !(@user && @user.authenticate(params[:password]))
      flash.now[:alert] = "Invalid username or password"
      render :new  # Render the login form again
    else
      flash.now[:notice] = ""
    end
  end

  # Handle the logout process
  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: 'You have been logged out.'
  end
end
