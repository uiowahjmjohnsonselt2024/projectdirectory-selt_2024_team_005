class MultiplayerChannel < ApplicationCable::Channel
  def subscribed
    # Called when a user subscribes to the channel (enters the world)
    stream_from "multiplayer_#{params[:world_id]}" # Broadcasting to a specific world

    # Notify other players that this user has joined
    ActionCable.server.broadcast(
      "multiplayer_#{params[:world_id]}",
      message: "#{current_user.username} has entered the world."
    )
  end

  def unsubscribed
    # Called when a user unsubscribes (leaves the world)
    ActionCable.server.broadcast(
      "multiplayer_#{params[:world_id]}",
      message: "#{current_user.username} has left the world."
    )
  end
end
