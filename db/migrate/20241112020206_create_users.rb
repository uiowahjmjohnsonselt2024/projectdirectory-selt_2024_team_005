class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users, id: false do |t|
      t.string :email, null: false
      t.string :username, null: false, primary_key: true
      t.string :password_digest, null: false
      t.integer :shard_balance, null: false
      t.timestamps
    end
    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
  end
end
