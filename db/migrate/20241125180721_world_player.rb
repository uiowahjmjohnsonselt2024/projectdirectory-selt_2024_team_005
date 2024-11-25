class WorldPlayer < ActiveRecord::Migration[7.2]
  def change
    create_table :world_players do |t|
      t.references :world, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end