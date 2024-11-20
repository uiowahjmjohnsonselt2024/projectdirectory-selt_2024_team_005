class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])
    @character = Character.find_by(username: params[:username])
  end

  def buy_shards
    @user = User.find_by!(username: params[:username])
    @character = Character.find_by(username: params[:username])
  end

  def process_payment
    @user = User.find_by!(username: params[:username])
    @shards = params[:shards].to_i

    # Validate the selected shards amount
    unless [ 5, 10, 15, 20 ].include?(@shards)
      flash[:alert] = "Invalid shards amount selected."
      redirect_to buy_shards_user_path(@user.username) and return
    end

    # Validate credit card information (basic validation)
    cc_number = params[:cc_number]
    cc_expiration = params[:cc_expiration]
    cc_cvv = params[:cc_cvv]

    if cc_number.blank? || cc_expiration.blank? || cc_cvv.blank?
      flash[:alert] = "Please fill in all credit card information."
      redirect_to buy_shards_user_path(@user.username) and return
    end

    unless cc_number.match(/\A\d{16}\z/)
      flash[:alert] = "Invalid credit card number."
      redirect_to buy_shards_user_path(@user.username) and return
    end

    unless cc_expiration.match(/\A(0[1-9]|1[0-2])\/\d{2}\z/)
      flash[:alert] = "Invalid expiration date format."
      redirect_to buy_shards_user_path(@user.username) and return
    end

    unless cc_cvv.match(/\A\d{3,4}\z/)
      flash[:alert] = "Invalid CVV."
      redirect_to buy_shards_user_path(@user.username) and return
    end

    # Simulate payment processing (since we're not integrating an actual payment gateway)
    # In a real application, you would integrate with a payment API here.

    # Update the user's shard balance
    @character = Character.find_by(username: params[:username])

    if @character.nil?
      flash[:alert] = "Character not found."
      redirect_to user_path(@user.username) and return
    end

    @character.shard_balance += @shards

    if @character.save
      flash[:notice] = "Successfully purchased #{@shards} shards."
      redirect_to user_path(@user.username)
    else
      flash[:alert] = "Unable to update shard balance."
      redirect_to user_path(@user.username)
    end
  end


  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # Check if the username or email already exists
    if User.exists?(username: @user.username) || User.exists?(email: @user.email)

      render :new  # Render the new user form again without saving the user
      flash.now[:notice] = "Email/Username is already taken"
    elsif @user.save
      flash.now[:notice] = "Account successfully created! Please log in."
      redirect_to login_path  # Redirect to the login page after successful account creation
    else
      flash.now[:notice] = ""
      render :new  # Render the new user form again with error messages
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation)
  end
  def destroy
    @user = User.find_by!(username: params[:username])
    @user.destroy
    # flash[:warning] = "Your account has been successfully deleted."
    redirect_to root_path
  end
end
