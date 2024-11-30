class Item < ApplicationRecord
  belongs_to :itemable, polymorphic: true
  delegate :name, :icon, :description, :atk_bonus, :def_bonus, :hp_regen, to: :itemable

  before_save :set_default_cost, if: :new_record?

  def category
    itemable_type
  end

  private

  def set_default_cost
    self.cost ||= 1
  end
end
