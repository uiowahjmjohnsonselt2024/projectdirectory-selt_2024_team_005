class CharactersController < ApplicationController
  before_action :set_character

  def new
    @character = Character.new
  end
  def create
    @character = Character.new(character_params)
    @character.username = @user.username
    @character.grid_id = 1 # Initialize as 1
    @character.cell_id = Grid.find(1).cells.order(:cell_id).first.cell_id # Initialize as Cell R0C0
    @character.health = 100
    @character.shard_balance = 0
    @character.experience = 0
    @character.level = 1

    # This need to be modified when inventory is setup!
    # Find the maximum inv_id in the inventories table and add 1 to it
    max_inv_id = Inventory.maximum(:inv_id) || 0
    new_inv_id = max_inv_id + 1

    # Create a new inventory with the new_inv_id
    @inventory = Inventory.create!(inv_id: new_inv_id)
    @character.inv_id = @inventory.inv_id

    if @character.save
      redirect_to home_path, notice: "Character created successfully."
    else
      flash.now[:alert] = "Failed to create character."
      render :new
    end
  end

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

    # no need to set_character if the user is going to create a new character
    if action_name != 'new' && action_name != 'create'
      @character = Character.find_by(username: @user.username)
      if @character.nil?
        render json: { status: "error", message: "Character not found" }, status: :not_found and return
      end
    end

  end

  def character_params
    params.require(:character).permit(:cell_id, :character_name)
  end
end
