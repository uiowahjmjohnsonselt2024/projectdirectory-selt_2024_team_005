class Cell < ApplicationRecord
  belongs_to :grid

  # Add other states for cells

  validates :row, :col, presence: true
end
