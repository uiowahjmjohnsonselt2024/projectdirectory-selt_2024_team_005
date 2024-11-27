class Item < ApplicationRecord
  belongs_to :itemable, polymorphic: true
  delegate :name, :icon, :description, :atk_bonus, :def_bonus, :hp_regen, to: :itemable

  def category
    itemable_type
  end
end