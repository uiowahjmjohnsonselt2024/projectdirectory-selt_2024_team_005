class CharactersController < ApplicationController
  before_action :set_character

  def update
    if @character.update(character_params)
      # After updating character position, check for monster encounter
      cell = Cell.find(@character.cell_id)
      mons_prob = cell.mons_prob || 0.0
      random_number = rand # Generates a random float between 0.0 and 1.0
      if random_number <= mons_prob
        # Monster encountered
        monster = generate_monster
        render json: { status: "ok", cell_id: @character.cell_id, monster: monster }, status: :ok
      else
        # No monster encountered
        render json: { status: "ok", cell_id: @character.cell_id }, status: :ok
      end
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

  def generate_monster
    atk = rand(5..15)  # Random attack between 5 and 15
    def_stat = rand(5..15)  # Random defense between 5 and 15
    { atk: atk, def: def_stat }
  end
end
