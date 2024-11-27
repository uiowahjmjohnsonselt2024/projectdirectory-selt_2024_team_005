class Inventory < ApplicationRecord
  before_save :set_default_items

  private

  def set_default_items
    self.items = (items || []).first(12) # Inventory only takes first 12 items defined
    self.items += Array.new(12 - self.items.size, nil) # Pad with nil up to 12
  end
end
