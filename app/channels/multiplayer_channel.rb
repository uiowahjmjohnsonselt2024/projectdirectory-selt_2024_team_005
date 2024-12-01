class MultiplayerChannel < ApplicationCable::Channel
  def subscribed
<<<<<<< HEAD
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
=======
    stream_from "multiplayer_channel_#{params[:room]}"
  end

  def receive(data)
    # Empty
    # if data["action"] == "move"
    #   handle_move(data["direction"])
    # end
    puts "Received data on MultiplayerChannel: #{data.inspect}"
  end

  # If needed, private func
  # private
  # def handle_move(direction)
  #   # Move logic
  # end
>>>>>>> bd3e9e9115042199b9e47c0ac8507840173daca7
end
