class UserGridVisibility < ApplicationRecord
  belongs_to :user, foreign_key: :username, primary_key: :username
  belongs_to :grid, foreign_key: :grid_id, primary_key: :grid_id
  validates :visibility, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: Grid::GRID_SIZE }
end
