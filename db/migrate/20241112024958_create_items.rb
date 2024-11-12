class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items, id: false do |t|
      t.integer :item_id, primary_key: true, null: false
      t.string :name, null: false
      t.string :category, null: false
      t.integer :cost, null: false
      t.timestamps
    end
    add_index :items, :item_id, unique: true
  end
end
