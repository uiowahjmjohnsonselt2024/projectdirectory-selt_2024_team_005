class CreateArmors < ActiveRecord::Migration[6.0]
  def change
    create_table :armors, primary_key: :armor_id, id: :serial do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :icon, null: false
      t.integer :def_bonus, null: false
      t.timestamps
    end
  end
end
