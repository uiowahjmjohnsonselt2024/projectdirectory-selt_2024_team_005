class CreateCharacters < ActiveRecord::Migration[7.2]
  def change
    # create_table :characters do |t|
    #   t.belongs_to :users, null: false, foreign_key: true
    #   t.string :character_name, null: false, primary_key: true
    #   t.string :username, null: false
    #   t.integer :health, null: false
    #   t.integer :shard_balance, null: false
    #   t.integer :experience, null: false
    #   t.integer :level, null: false
    #   t.integer :grid_id, null: false
    #   t.integer :cell_id, null: false
    #   t.integer :inv_id, null: false
    #   t.timestamps
    # end
    # add_foreign_key :characters, :grids, column: :grid_id
    # add_foreign_key :characters, :cells, column: :cell_id
    # add_foreign_key :characters, :inventories, column: :inv_id
  end
end
