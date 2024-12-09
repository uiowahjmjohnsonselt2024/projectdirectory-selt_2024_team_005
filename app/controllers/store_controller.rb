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

    # Check if the user already has visibility for this grid
    user_grid_visibility = UserGridVisibility.find_by(username: @user.username, grid_id: @grid.id)

    if user_grid_visibility
      # If the visibility record exists, update visibility to 6 (purchased/visible)
      user_grid_visibility.update(visibility: 6)
    else
      # If no record exists, create a new one with visibility set to 6
      user_grid_visibility = UserGridVisibility.create(
        username: @user.username,
        grid_id: @grid.id,
        visibility: 6
      )
    end

    # Check if the operation was successful
    if user_grid_visibility.persisted? || user_grid_visibility.valid?
      flash[:notice] = "Grid purchased successfully!"
      redirect_to store_path(@user.username)
    else
      flash[:alert] = "There was an error purchasing the grid."
      redirect_to store_path(@user.username)
    end
  end
end
