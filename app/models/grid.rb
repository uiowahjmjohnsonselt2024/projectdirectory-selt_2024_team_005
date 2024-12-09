class Grid < ApplicationRecord
  self.primary_key = "grid_id"

  has_many :cells, foreign_key: "grid_id", primary_key: "grid_id", dependent: :destroy

  after_create :generate_cells

  GRID_SIZE = 12

  # Extended sets of single-word, lowercase weather and terrain words
  WEATHER_WORDS = %w[
    sunny cloudy windy rainy foggy stormy clear overcast humid dry
    misty snowy icy breezy thunderous drizzly scorching freezing
    balmy damp cool warm hot blustery tropical arid frigid hail
  ].freeze

  TERRAIN_WORDS = %w[
    grass sand stone dirt mud swamp lava ice rock moss
    gravel clay tundra meadow forest desert canyon jungle
    plain valley hill mountain glacier marsh reef cavern
    plateau savanna bayou bog prairie dune crater
  ].freeze

  def generate_cells
    cells_in_grid = []

    (0...GRID_SIZE).each do |row|
      (0...GRID_SIZE).each do |col|
        cell_id = grid_id * 10_000 + row * 100 + col
        cell_loc = "R#{row}C#{col}"

        # Randomly pick weather and terrain from extended arrays
        weather = WEATHER_WORDS.sample
        terrain = TERRAIN_WORDS.sample

        cells_in_grid << {
          cell_id: cell_id,
          cell_loc: cell_loc,
          mons_prob: 0.18,
          disaster_prob: 0.15,
          weather: weather,
          terrain: terrain,
          has_store: [true, false].sample,
          grid_id: self.grid_id,
          created_at: Time.current,
          updated_at: Time.current
        }
      end
    end

    Cell.insert_all(cells_in_grid)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Something went wrong when generating the grid: #{e.message}"
  end
end
