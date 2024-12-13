class Potion < ApplicationRecord
  has_one :item, as: :itemable

  before_save :set_default_description, if: :new_record?

  def update_hp_regen
    self.hp_regen *= item.level * item.rarity
    self.description = "HP +#{self.hp_regen}"
    save!
  end

  private

  def set_default_description
    self.description ||= "HP +#{hp_regen}" if hp_regen.present?

    self.icon ||= "potion.png"
  end
end
