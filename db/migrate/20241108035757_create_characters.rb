class CreateCharacters < ActiveRecord::Migration[8.0]
  def change
    create_table :characters do |t|
      t.integer :health
      t.integer :experience
      t.integer :level
      t.string :name
      t.integer :strength
      t.integer :agility

      t.timestamps
    end
  end
end
