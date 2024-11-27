class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:world_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
    # Save the message to the database
    message = Message.create!(
      user: current_user,
      world_id: params[:world_id],
      content: data['message']
    )

    # Broadcast the message to the chat channel
    ActionCable.server.broadcast(
      "chat_#{params[:world_id]}",
      username: current_user.username,
      message: message.content
    )
  end
end
