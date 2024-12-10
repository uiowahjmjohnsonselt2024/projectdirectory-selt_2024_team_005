class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.text :content
      t.string :username
      t.string :channel_type
      t.string :room_id

      t.timestamps
    end
  end
end
