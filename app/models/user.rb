require "open_exchange_rates"
class User < ApplicationRecord
  has_secure_password
  has_one :character, foreign_key: "username", primary_key: "username",  dependent: :destroy


  # For Multiplayer, worlds(servers)/world_players(the players in that server)
  has_many :world_players, dependent: :destroy
  has_many :worlds, through: :world_players

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
    config.app_id = "541c6dbbdf244c82bd71151575e47f27"
  end
  def get_exchange_rate(currency)
    fx = OpenExchangeRates::Rates.new
    fx.convert(1, from: "USD", to: currency)
  end

  private

  def initialize_grid_visibilities
    # puts "Initializing grid visibilities for #{self.username}"
    Grid.find_each do |grid|
      user_grid_visibilities.create!(grid_id: grid.grid_id, visibility: 6)
    end
  end
end
