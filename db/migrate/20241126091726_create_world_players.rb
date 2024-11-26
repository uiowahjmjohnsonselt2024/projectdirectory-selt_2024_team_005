class CreateWorldPlayers < ActiveRecord::Migration[7.2]
  def change
    create_table :world_players do |t|
      t.references :user, null: false, foreign_key: true
      t.references :grids, null: false, foreign_key: { to_table: :grids, primary_key: :id }
      # t.references :world, null: false, foreign_key: true
      t.timestamps
    end

    # Add unique index to enforce each user can only be in one world at a time
    add_index :world_players, [:user_id, :grids_id], unique: true
  end
end
