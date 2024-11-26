class CreateWorlds < ActiveRecord::Migration[7.2]
  def change
    create_table :worlds do |t|
      t.string :name, null: false
      t.references :grid, null: false, foreign_key: { to_table: :grids, primary_key: :grid_id }
      t.timestamps
    end
  end
end
