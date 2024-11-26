class Character < ApplicationRecord
  belongs_to :user, foreign_key: :username, primary_key: :username
  belongs_to :grid, foreign_key: :grid_id, primary_key: :grid_id
  belongs_to :cell, foreign_key: :cell_id, primary_key: :cell_id
  belongs_to :inventory, foreign_key: :inv_id, primary_key: :inv_id

  validates :username, presence: true
  validates :level, presence: true, numericality: { greater_than_or_equal_to: 1 }
end
