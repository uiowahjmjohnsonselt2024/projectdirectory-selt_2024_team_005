class User < ApplicationRecord
  has_one :character, foreign_key: "username", primary_key: "username",  dependent: :destroy
end
