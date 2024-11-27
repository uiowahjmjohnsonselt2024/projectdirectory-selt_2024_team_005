class MultiplayerChannel < ApplicationCable::Channel
  def subscribed
    # Called when a user subscribes to the channel (enters the world)
    stream_from "multiplayer_#{params[:world_id]}" # Broadcasting to a specific world
  end

  def unsubscribed
    # Called when a user unsubscribes (leaves the world)
  end
end
