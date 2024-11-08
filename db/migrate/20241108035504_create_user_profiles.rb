class CreateUserProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_profiles do |t|
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
