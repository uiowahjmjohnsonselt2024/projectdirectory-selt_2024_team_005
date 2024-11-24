class CreateGrids < ActiveRecord::Migration[7.2]
  def change
    create_table :grids, id: false do |t|
      t.integer :grid_id, primary_key: true, null: false
      t.integer :size, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
