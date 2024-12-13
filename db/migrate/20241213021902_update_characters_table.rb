class UpdateCharactersTable < ActiveRecord::Migration[7.2]
  def change
    rename_column :characters, :health, :current_hp
    rename_column :characters, :experience, :current_exp

    add_column :characters, :max_hp, :integer, null: false
    add_column :characters, :exp_to_level, :integer, null: false
    add_column :characters, :weapon_item_id, :integer, null: false
    add_column :characters, :armor_item_id, :integer, null: false
  end
end
