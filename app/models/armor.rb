class Armor < ApplicationRecord
  has_one :item, as: :itemable
end