class AddOnlineStatusToCharacters < ActiveRecord::Migration[7.2]
  def change
    add_column :characters, :online_status, :boolean
  end
end
