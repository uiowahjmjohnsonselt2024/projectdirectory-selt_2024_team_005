class StoreController < ApplicationController
  def shards_store
    @user = User.find_by!(username: params[:username])
    @character = Character.find_by(username: params[:username])
    @items = Item.all
    @grid = Grid.find_by(grid_id: params[:id])
    @grids = Grid.all
  end
  def buy_item
    @user = User.find_by!(username: params[:username])
    @character = Character.find_by(username: params[:username])
    item = Item.find(params[:id])

    if @character.nil?
      redirect_to user_path(@user.username) and return
    end

    if @user.shard_balance.nil?
      flash[:alert] = "Insufficient balance to purchase this item."
      redirect_to store_path and return
    end
    if @user.shard_balance < item.cost
      flash[:alert] = "Insufficient balance to purchase this item."
      redirect_to store_path and return
    end
    inventory = Inventory.find(@character.inv_id) # Find the inventory using the character's inventory ID
    inventory.add_item(item.item_id)
    @user.shard_balance -= item.cost

    if @user.save && @character.save && inventory.save
      flash[:notice] = "Item purchased successfully."
      redirect_to store_path
    else
      flash[:alert] = "Unable to purchase item."
      redirect_to store_path
    end
  end

  def buy_grid
    @user = User.find_by!(username: params[:username])
    @grid = Grid.find(params[:id])

    # Check if user has sufficient shard balance
    if @user.shard_balance < @grid.cost
      flash[:alert] = "You do not have enough shards to purchase this grid."
      redirect_to store_path(@user.username) and return
    end

    # Deduct shards from user's balance
    @user.shard_balance -= @grid.cost
    @user.save

    # Create a new user_grid_visibility record to grant the grid to the user
    user_grid_visibility = UserGridVisibility.create(
      username: @user.username,
      grid_id: @grid.grid_id,
      visibility: 1  # Set to "purchased"/"visible" status
    )

    if user_grid_visibility.persisted?
      flash[:notice] = "Grid purchased successfully!"
      redirect_to store_path(@user.username)
    else
      flash[:alert] = "There was an error purchasing the grid."
      redirect_to store_path(@user.username)
    end
  end
end
