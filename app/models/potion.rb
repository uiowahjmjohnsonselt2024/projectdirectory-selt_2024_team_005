class Potion < ApplicationRecord
  has_one :item, as: :itemable

  after_initialize :set_default_description, if: :new_record?

  private

  def set_default_description
    self.description ||= "HP +#{hp_regen}" if hp_regen.present?

    self.icon ||= "potion.png"
  end
end
