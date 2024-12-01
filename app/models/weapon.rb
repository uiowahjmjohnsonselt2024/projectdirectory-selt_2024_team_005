class Weapon < ApplicationRecord
  has_one :item, as: :itemable

  after_initialize :set_default_description, if: :new_record?

  private

  def set_default_description
    self.description ||= "ATK +#{atk_bonus}" if atk_bonus.present?

    self.icon ||= "sword.png"
  end
end
