require "open_exchange_rates"
class User < ApplicationRecord
  has_secure_password
  has_one :character, foreign_key: "username", primary_key: "username",  dependent: :destroy
  has_many :user_grid_visibilities, foreign_key: "username", dependent: :destroy
  has_many :grids, through: :user_grid_visibilities
  validates :shard_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  after_create :initialize_grid_visibilities

  # Method to get visibility for a specific grid
  def visibility_for(grid)
    ugv = user_grid_visibilities.find_or_create_by(grid_id: grid.grid_id) do |new_ugv|
      new_ugv.visibility = 6  # Default visibility
    end
    puts ugv.visibility
    ugv.visibility
  end

  # Method to set visibility for a specific grid
  def set_visibility_for(grid, new_visibility)
    ugv = user_grid_visibilities.find_or_initialize_by(grid_id: grid.grid_id)
    ugv.visibility = new_visibility
    ugv.save
  end

  OpenExchangeRates.configure do |config|
    config.app_id = "b18f902551cc4ef9af757b0ab10b39b5"
  end
  def get_exchange_rate(currency)
    fx = OpenExchangeRates::Rates.new
    fx.convert(1, from: "USD", to: currency)
  end

  private

  def initialize_grid_visibilities
    Grid.find_each do |grid|
      visibility = (grid.name == 'Earth') ? 6 : 0  # Set visibility to 6 for Earth, 0 for all other grids
      user_grid_visibilities.create!(grid_id: grid.grid_id, visibility: visibility)
    end
  end
end
