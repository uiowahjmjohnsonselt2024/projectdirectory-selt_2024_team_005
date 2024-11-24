class Potion < ApplicationRecord
  has_one :item, as: :itemable
end