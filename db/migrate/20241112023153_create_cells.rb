class CreateCells < ActiveRecord::Migration[7.2]
  def change
    create_table :cells, id: false do |t|
      t.integer :cell_id, primary_key: true, null: false
      t.string :cell_loc, null: false
      t.float :mons_prob
      t.float :disaster_prob
      t.string :weather, null: false
      t.string :terrain, null: false
      t.boolean :has_store, null: false
      t.integer :grid_id, null: false
      t.timestamps
    end
    add_index :cells, :cell_id, unique: true
    add_foreign_key :cells, :grids, column: :grid_id, primary_key: :grid_id
  end
end
