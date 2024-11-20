class User < ApplicationRecord
  has_one :character, foreign_key: "username", primary_key: "username",  dependent: :destroy

  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, confirmation: true
  validates :password_confirmation, presence: true
end

