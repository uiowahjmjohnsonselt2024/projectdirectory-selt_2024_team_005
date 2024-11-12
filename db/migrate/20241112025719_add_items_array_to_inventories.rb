class AddItemsArrayToInventories < ActiveRecord::Migration[7.2]
  def change
    add_column :inventories, :items, :integer, array: true, default: []
  end
end
