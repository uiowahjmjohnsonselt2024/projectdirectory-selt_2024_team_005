class Armor < ApplicationRecord
  has_one :item, as: :itemable

  before_save :set_default_description, if: :new_record?

  def update_def_bonus
    self.def_bonus *= item.level * item.rarity
    self.description = "DEF +#{self.def_bonus}"
    save!
  end

  private

  def set_default_description
    self.description ||= "DEF +#{def_bonus}" if def_bonus.present?

    self.icon ||= "armor.png"
  end
end
