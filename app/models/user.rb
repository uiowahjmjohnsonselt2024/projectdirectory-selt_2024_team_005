class User < ApplicationRecord
  has_one :character, foreign_key: "username", primary_key: "username",  dependent: :destroy
  has_secure_password
  validates :username, presence: true, uniqueness: true
end
