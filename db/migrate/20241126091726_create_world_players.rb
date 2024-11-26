class CreateWorldPlayers < ActiveRecord::Migration[7.2]
  def change
    create_table :world_players, id: false do |t|
      # Use username as the foreign key
      t.string :username, null: false
      t.integer :grid_id, null: false
      t.references :world, null: false, foreign_key: true
      t.timestamps
    end

    # Add foreign key constraints
    add_foreign_key :world_players, :users, column: :username, primary_key: :username
    add_foreign_key :world_players, :grids, column: :grid_id, primary_key: :grid_id

    # Add unique index to ensure each user can only be in one world at a time
    add_index :world_players, [:username, :grid_id], unique: true
  end
end
