class Inventory < ApplicationRecord
  before_save :set_default_items, if: :new_record?

  def add_item(item_id)
    slot = items.index(nil)
    if slot
      items[slot] = item_id
      save
    else
      puts "Inventory is full!"
    end
  end

  def remove_item(index)
    if index >= 0 && index < items.size
      items[index] = nil

      # Shift all items after the removed item to the left
      (index...(items.size - 1)).each do |i|
        items[i] = items[i + 1]
      end

      items[items.size - 1] = nil
      save
    else
      puts "Invalid index!"
    end
  end

  private

  def set_default_items
    self.items = (items || []).first(12) # Inventory only takes first 12 items defined
    self.items += Array.new(12 - self.items.size, nil) # Pad with nil up to 12
  end
end
