class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])
    @character = Character.find_by(username: params[:username])
  end

  def buy_shards
    @currencies = %w[USD EUR GBP JPY AUD CAD CHF CNY SEK NZD]
    @user = User.find_by!(username: params[:username])
    @character = Character.find_by(username: params[:username])
    @exchange_rates = @currencies.each_with_object({}) do |currency, rates|
      rates[currency] = @user.get_exchange_rate(currency)
    end
  end

  def process_payment
    @user = User.find_by!(username: params[:username])

    @amount = params[:amount].to_f
    @currency = params[:currency]
    # Validate inputs
    if @amount <= 0
      flash[:alert] = "Please enter a valid amount."
      redirect_to buy_shards_user_path(@user.username) and return
    end
    # Currency exchange
    exchange_rate = @user.get_exchange_rate(@currency)
    amount_in_usd = @amount / exchange_rate
    shards_to_credit = amount_in_usd.floor

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

    @user.shard_balance += shards_to_credit

    if @character.save
      flash[:notice] = "Successfully purchased #{shards_to_credit} shards."
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
      # Automatically create a character and a inventory for a new user
      max_inv_id = Inventory.maximum(:inv_id) || 0
      new_inv_id = max_inv_id + 1
      # Create a new inventory with the new_inv_id
      @inventory = Inventory.create!(inv_id: new_inv_id)
      # Create a new character
      @character = Character.create!(
        character_name: @user.username,   # This should be able to modify
        username: @user.username,
        health: 100,
        shard_balance: 0,
        experience: 0,
        level: 1,
        grid_id: 1,
        cell_id: Grid.find(1).cells.order(:cell_id).first.cell_id,
        inv_id: @inventory.inv_id
      )
      flash.now[:notice] = "Account and a default character successfully created! Please log in."
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
    flash[:warning] = "Your account has been successfully deleted."
    redirect_to root_path
  end
end
