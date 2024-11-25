class CreateUserGridVisibilities < ActiveRecord::Migration[7.2]
  def change
    create_table :user_grid_visibilities do |t|
      t.string :username, null: false
      t.integer :grid_id, null: false
      t.integer :visibility, null: false, default: 0

      t.timestamps
    end
    add_index :user_grid_visibilities, [ :username, :grid_id ], unique: true
    add_foreign_key :user_grid_visibilities, :users, column: :username, primary_key: :username
    add_foreign_key :user_grid_visibilities, :grids, column: :grid_id, primary_key: :grid_id
  end
end
