class World < ApplicationRecord
  has_one :grid
  has_many :world_players, dependent: :destroy
  has_many :players, through: :world_players, source: :user

  validates :name, presence: true
end
