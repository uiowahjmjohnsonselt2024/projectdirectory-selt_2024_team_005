class MultiplayerChannel < ApplicationCable::Channel
  def subscribed
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
end
