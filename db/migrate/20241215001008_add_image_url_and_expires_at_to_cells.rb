class AddImageUrlAndExpiresAtToCells < ActiveRecord::Migration[7.2]
  def change
    add_column :cells, :image_url, :string
    add_column :cells, :expires_at, :datetime
  end
end
