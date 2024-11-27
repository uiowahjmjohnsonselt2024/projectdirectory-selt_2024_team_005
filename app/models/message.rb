class Message < ApplicationRecord
  belongs_to :user, foreign_key: :username
  belongs_to :world

  validates :content, presence: true

  def broadcast_message
    ActionCable.server.broadcast(
      "multiplayer_#{self.world.id}",  # Broadcast to the correct world
      message: self.content,
      username: self.username
    )
  end
end
