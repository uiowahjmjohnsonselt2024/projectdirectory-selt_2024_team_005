class World < ApplicationRecord
  belongs_to :grid # A world is linked to an existing grid
  validates :name, presence: true
  validates :grid, presence: true # Ensure a grid is always associated with a world
end
