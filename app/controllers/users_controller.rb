class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])
    @character = Character.find_by(username: params[:username])
  end

  def destroy
  end
end
