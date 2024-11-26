class WorldPlayer < ApplicationRecord
  belongs_to :world
  belongs_to :user, foreign_key: :username, primary_key: :username
end
