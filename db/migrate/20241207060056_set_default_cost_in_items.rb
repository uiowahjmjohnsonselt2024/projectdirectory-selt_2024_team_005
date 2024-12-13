class SetDefaultCostInItems < ActiveRecord::Migration[7.2]
  def change
    change_column_default :items, :cost, from: nil, to: 1
  end
end
