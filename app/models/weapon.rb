class Weapon < ApplicationRecord
  has_one :item, as: :itemable

  before_save :set_default_description, if: :new_record?

  def update_atk_bonus
    self.atk_bonus *= item.level * item.rarity
    self.description = "ATK +#{self.atk_bonus}"
    save!
  end

  private

  def set_default_description
    self.description ||= "ATK +#{atk_bonus}" if atk_bonus.present?

    self.icon ||= "sword.png"
  end
end
