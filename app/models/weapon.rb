class Weapon < ApplicationRecord
  has_one :item, as: :itemable
end