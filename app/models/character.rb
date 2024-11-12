class Character < ApplicationRecord
  belongs_to :user, optional: true
end
