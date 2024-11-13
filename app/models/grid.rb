class Grid < ApplicationRecord
  # belongs_to :user
  has_many :cells
  GRID_SIZE = 6
  after_create :initialize_cells    # Automatically initialize cells

  private
  def initialize_cells
    GRID_SIZE.times do |row|
      GRID_SIZE.times do |col|
        cells.create(row: row, col: col)
      end
    end
  end
end