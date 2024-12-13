class UpdateItemsForPolymorphic < ActiveRecord::Migration[7.2]
  def change
    remove_column :items, :name, :string
    remove_column :items, :category, :string

    add_column :items, :itemable_id, :integer, null: false
    add_column :items, :itemable_type, :string, null: false

    add_index :items, [ :itemable_type, :itemable_id ], name: "index_items_on_itemable_type_and_itemable_id"
  end
end
