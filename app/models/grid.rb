# app/models/grid.rb

class Grid < ApplicationRecord
  self.primary_key = 'grid_id'

  has_many :cells, foreign_key: 'grid_id', primary_key: 'grid_id', dependent: :destroy

  GRID_SIZE = 6

  after_create :generate_cells

  def generate_cells(rows = GRID_SIZE-1, cols = GRID_SIZE-1)
    cells_in_grid = []
    (0..rows).each do |row|
      (0..cols).each do |col|
        # grid_id=1, row=0, col=0 => 10000
        # grid_id=20, row=3, col=5 => 200305
        cell_id = grid_id * 10_000 + row * 100 + col
        cell_loc = "R#{row}C#{col}"   # Record the location: e.g., R1C1, R1C2, ..., R6C6
        cells_in_grid << {
          cell_id: cell_id,
          cell_loc: cell_loc,
          mons_prob: rand,
          disaster_prob: rand,
          weather: 'sunny',
          terrain: 'grass',
          has_store: [true, false].sample,
          grid_id: self.grid_id,
          created_at: Time.current,
          updated_at: Time.current
        }
      end
    end

    Cell.insert_all(cells_in_grid)

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Something went wrong when generate grid: #{e.message}"
  end
end
