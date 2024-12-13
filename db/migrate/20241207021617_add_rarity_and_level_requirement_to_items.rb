class AddRarityAndLevelRequirementToItems < ActiveRecord::Migration[7.2]
  def change
    add_column :items, :rarity, :integer, default: 1, null: false
    add_column :items, :level_requirement, :integer, default: 1, null: false
  end
end
