class CharactersController < ApplicationController
  before_action :set_character

  def update
    if @character.update(character_params)
      render json: { status: "ok", cell_id: @character.cell_id }, status: :ok
    else
      render json: { status: "error", errors: @character.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_character
    @user = User.find_by(username: session[:username])
    if @user.nil?
      render json: { status: "error", message: "User not found" }, status: :not_found and return
    end

    @character = Character.find_by(username: @user.username)
    if @character.nil?
      render json: { status: "error", message: "Character not found" }, status: :not_found and return
    end
  end

  def character_params
    params.require(:character).permit(:cell_id, :character_name)
  end
end
