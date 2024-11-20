class PasswordResetsController < ApplicationController
  def new

  end

  def create
    if params[:email].present? and params[:email] =~ URI::MailTo::EMAIL_REGEXP
      @user = User.find_by(email: params[:email])

      if @user.present?
        # Send email
        PasswordMailer.with(user: @user).reset.deliver_later
      end
      # Message is displayed even if user does not exist
      redirect_to root_path, notice: "Email sent. Please check your email."
    else
      flash[:alert] = "Invalid email."
      redirect_to forgot_password_path
    end
  end

  def edit
    @user = User.find_signed!(params[:token], purpose: "password_reset")
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    # Change redirect path to login once login page has been completed
    redirect_to root_path, alert: "Your token has expired. Please try again."
  end

  def update
    @user = User.find_signed!(params[:token], purpose: "password_reset")
    if @user.update(password_params)
      # Change redirect path to login once login page has been completed
      redirect_to root_path, notice: "Your password was reset successfully. Please sign in again."
    else
      # BUG: this flash message doesn't show
      flash.now[:alert] = "Passwords do not match."
      render :edit
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end