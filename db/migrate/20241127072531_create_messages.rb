class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.text :content
      t.string :username, null: false  # Reference to the user's username
      t.references :world, null: false, foreign_key: true
      t.timestamps
    end

    # Add foreign key constraints
    add_foreign_key :messages, :users, column: :username, primary_key: :username
  end
end
