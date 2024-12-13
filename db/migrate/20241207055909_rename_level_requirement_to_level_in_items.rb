class RenameLevelRequirementToLevelInItems < ActiveRecord::Migration[7.2]
  def change
    rename_column :items, :level_requirement, :level
  end
end
