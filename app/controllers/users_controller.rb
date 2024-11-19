class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])
    @character = Character.find_by(username: params[:username])
  end

  def buy_shards
    @currencies = %w[USD EUR GBP JPY AUD CAD CHF CNY SEK NZD]
    @user = User.find_by!(username: params[:username])
    @character = Character.find_by(username: params[:username])
  end

  def process_payment
    @user = User.find_by!(username: params[:username])
    # @shards = params[:shards].to_i

    @amount = params[:amount].to_f
    @currency = params[:currency]
    # Validate inputs
    if @amount <= 0
      flash[:alert] = "Please enter a valid amount."
      redirect_to buy_shards_user_path(@user.username) and return
    end
    # Currency exchange
    exchange_rate = get_exchange_rate(@currency)
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

    @character.shard_balance += shards_to_credit

    if @character.save
      flash[:notice] = "Successfully purchased #{shards_to_credit} shards."
      redirect_to user_path(@user.username)
    else
      flash[:alert] = "Unable to update shard balance."
      redirect_to user_path(@user.username)
    end
  end

  def get_exchange_rate(currency)
    # Simulate exchange rates for the purpose of this mock system
    exchange_rates = {
      'USD' => 1.0,
      'EUR' => 0.85,
      'GBP' => 0.75,
      'JPY' => 110.0,
      'AUD' => 1.35,
      'CAD' => 1.25,
      'CHF' => 0.90,
      'CNY' => 6.5,
      'SEK' => 8.5,
      'NZD' => 1.4
    }
    exchange_rates[currency] || 1.0
  end

  def destroy
    @user = User.find_by!(username: params[:username])
    @user.destroy
    flash[:warning] = "Your account has been successfully deleted."
    redirect_to root_path
  end
end
