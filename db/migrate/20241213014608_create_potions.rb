class CreatePotions < ActiveRecord::Migration[6.0]
  def change
    create_table :potions, primary_key: :potion_id, id: :serial do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :icon, null: false
      t.integer :hp_regen, null: false
      t.timestamps
    end
  end
end