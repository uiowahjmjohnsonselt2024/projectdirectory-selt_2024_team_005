class CreateWorlds < ActiveRecord::Migration[7.2]
  def change
    create_table :worlds do |t|
      t.string :name, null: false
      t.references :grid, null: false, foreign_key: true # Ensures world references an existing grid
      t.timestamps
    end
  end
end
