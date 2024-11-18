class Cell < ApplicationRecord
  belongs_to :grid

  validates :cell_loc, presence: true, uniqueness: { scope: :grid_id }    # In the same grid, cell_loc should be unique
  validates :weather, presence: true
  validates :terrain, presence: true
  validates :has_store, inclusion: { in: [true, false] }
end

