class AddIndexToMessages < ActiveRecord::Migration[7.2]
  def change
    add_index :messages, [ :username, :created_at ]
  end
end
