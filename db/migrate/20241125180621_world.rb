class Worlds < ActiveRecord::Migration[7.2]
  def change
    create_table :worlds do |t|
      t.string :name, null: false
      t.references :grid, foreign_key: true
      t.timestamps
    end
  end
end
