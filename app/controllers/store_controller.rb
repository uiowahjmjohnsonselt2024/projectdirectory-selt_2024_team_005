class StoreController < ApplicationController
  def shards_store
    @user = User.find_by!(username: params[:username])
    @character = Character.find_by(username: params[:username])
    @items = Item.all
    @grid = Grid.find_by(grid_id: params[:id])
  end
  def buy_item
    @user = User.find_by!(username: params[:username])
    @character = Character.find_by(username: params[:username])
    item = Item.find(params[:id])

    if @character.nil?
      redirect_to user_path(@user.username) and return
    end

    if @character.shard_balance.nil?
      flash[:alert] = "Insufficient balance to purchase this item."
      redirect_to store_path and return
    end
    if @character.shard_balance < item.cost
      flash[:alert] = "Insufficient balance to purchase this item."
      redirect_to store_path and return
    end
    inventory = Inventory.find(@character.inv_id) # Find the inventory using the character's inventory ID
    inventory.items << item.item_id
    @character.shard_balance -= item.cost

    if @character.save && inventory.save
      flash[:notice] = "Item purchased successfully."
      redirect_to store_path
    else
      flash[:alert] = "Unable to purchase item."
      redirect_to store_path
    end
  end
end
