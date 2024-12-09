class CreateWeapons < ActiveRecord::Migration[7.2]
  def change
    unless table_exists?(:weapons)
    create_table :weapons, primary_key: :weapon_id, id: :serial do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :icon, null: false
      t.integer :atk_bonus, null: false
      t.timestamps null: false
    end
  end
end
