class Character < ApplicationRecord
  belongs_to :user, foreign_key: "username", primary_key: "username",  optional: true
  belongs_to :inventory, foreign_key: "inv_id"

  validates :username, presence: true
  validates :shard_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :level, presence: true, numericality: { greater_than_or_equal_to: 1 }
end
