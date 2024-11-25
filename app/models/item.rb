class Item < ApplicationRecord
  belongs_to :itemable, polymorphic: true
  delegate :name, to: :itemable

  def category
    itemable_type
  end
end