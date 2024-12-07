class InventoryController < GridsController
  before_action :set_character_and_inventory

  def use_item
    item = Item.find(@inventory.items[params[:index].to_i]) # Ensure the item ID is passed correctly

    if item.category == "Potion"
      potion = item.itemable

      # Apply the effect of the potion
      @character.current_hp = [@character.max_hp, @character.current_hp + potion.hp_regen].min

      # Remove the item from the inventory
      @inventory.remove_item(params[:index].to_i)

      if @character.save && @inventory.save
        puts "#{potion.name} used! HP replenished by #{potion.hp_regen}."
      end
    else
      puts "This item cannot be used."
    end
  end

  def discard_item
    @inventory.remove_item(params[:index].to_i)
  end

  private

  def set_character_and_inventory
    @character = current_user.character # Assuming the character is associated with the current user
    @inventory = Inventory.find_by(inv_id: @character.inv_id)
  end

end
