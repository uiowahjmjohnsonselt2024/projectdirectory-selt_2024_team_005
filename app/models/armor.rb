class Armor < ApplicationRecord
  has_one :item, as: :itemable

  after_initialize :set_default_description, if: :new_record?

  private

  def set_default_description
    self.description ||= "DEF +#{def_bonus}" if def_bonus.present?

    self.icon ||= "armor.png"
  end
end
