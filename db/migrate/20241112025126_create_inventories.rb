class CreateInventories < ActiveRecord::Migration[7.2]
  def change
    create_table :inventories, id: false do |t|
      t.integer :inv_id, null: false, primary_key: true
      t.timestamps
    end
    add_index :inventories, :inv_id, unique: true
  end
end
