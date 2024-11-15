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
      redirect_to password_reset_path
    end
  end
end