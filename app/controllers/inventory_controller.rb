class InventoryController < GridsController
  before_action :set_character_and_inventory

  def use_item
    item = Item.find(@inventory.items[params[:index].to_i])

    case item.category
    when "Potion"
      use_potion(item)
    when "Weapon"
      equip_weapon(item)
    when "Armor"
      equip_armor(item)
    end

    respond_to do |format|
      format.js # Renders use_item.js.erb
      format.json { render json: { success: true, current_hp: @character.current_hp, inventory: @inventory } }
      format.html { redirect_to use_item_inventory_index_path }
    end
  end

  def discard_item
    @inventory.remove_item(params[:index].to_i)

    respond_to do |format|
      format.js # Renders use_item.js.erb
      format.json { render json: { success: true, inventory: @inventory } }
      format.html { redirect_to discard_item_inventory_index_path }
    end
  end

  private

  def set_character_and_inventory
    @character = current_user.character
    @inventory = Inventory.find_by(inv_id: @character.inv_id)
  end

  def use_potion(item)
    potion = item.itemable

    @character.current_hp = [@character.max_hp, @character.current_hp + potion.hp_regen].min

    @inventory.remove_item(params[:index].to_i)

    @character.save
    @inventory.save
  end

  def equip_weapon(item)
    weapon = item
    temp_weapon = @character.weapon_item_id

    @character.weapon_item_id = weapon.item_id
    @inventory.items[params[:index].to_i] = temp_weapon

    @character.save
    @inventory.save
  end

  def equip_armor(item)
    armor = item
    temp_armor = @character.armor_item_id

    @character.armor_item_id = armor.item_id
    @inventory.items[params[:index].to_i] = temp_armor

    @character.save
    @inventory.save
  end
end
