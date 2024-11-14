class Grid < ApplicationRecord
  has_many :cells, dependent: :destroy
end
