class CellsController < ApplicationController
  before_action :set_cell, only: [ :show, :update ]
  before_action :set_user

  def show
    @cell = Cell.find(params[:id])
    respond_to do |format|
      format.json { render json: @cell }
    end
  end

  def update
    @cell = Cell.find(params[:id])
    # Perform the disaster check whenever a character moves to a new cell
    disaster_message = check_for_disaster(@cell)

    # Respond with the disaster message and any other necessary data (e.g., cell info)
    respond_to do |format|
      format.json { render json: { disaster_message: disaster_message, cell: @cell } }
    end
  end

  private
  def check_for_disaster(cell)
    disaster_threshold = cell[:disaster_prob]
    if rand < disaster_threshold
      # add if @character has certain item in inventory, then divide disaster_threshold by 3
      # add this item to the inventory of our character
      # Add the item to store
      damage = 15
      @character = Character.find_by(username: @user.username)
      @character.send(:take_disaster_damage, damage)
      @character.save
      # Return the disaster message to the front-end
      "A disaster has occurred! <br> You lost #{damage} HP due to the disaster."
    end
  end
  def set_user
    @user = User.find_by(username: session[:username])
  end

  def set_cell
    @cell = Cell.find(params[:id])
  end
end
