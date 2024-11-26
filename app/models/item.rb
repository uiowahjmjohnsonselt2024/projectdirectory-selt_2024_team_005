class Item < ApplicationRecord
  belongs_to :itemable, polymorphic: true
  delegate :name, :icon, to: :itemable

  def category
    itemable_type
  end
end