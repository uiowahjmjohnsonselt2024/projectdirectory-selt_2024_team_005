class Character < ApplicationRecord
  belongs_to :user, foreign_key: "username", primary_key: "username",  optional: true
end
