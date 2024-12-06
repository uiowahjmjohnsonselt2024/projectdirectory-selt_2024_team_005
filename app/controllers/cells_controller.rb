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
    @character = Character.find_by(username: @user.username)
    inventory = Inventory.find(@character.inv_id)

    item_ids = inventory.items
    # Find the items in the inventory, using the correct primary key column
    items = Item.where(item_id: item_ids).includes(:itemable)
    # Check if any item is a Disaster Ward
    disaster_ward_item = items.find { |item| item.itemable.name == "Catastrophe Ward" }

    if disaster_ward_item
      disaster_threshold = disaster_threshold / 2.0
    end
    puts disaster_threshold
    puts "THRESHOLD"
    if rand < disaster_threshold
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
