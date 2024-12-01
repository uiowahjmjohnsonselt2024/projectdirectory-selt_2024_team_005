class ChatChannel < ApplicationCable::Channel
  def subscribed
<<<<<<< HEAD
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
    if message.persisted?
      ActionCable.server.broadcast(
        "chat_#{params[:world_id]}",
        username: current_user.username,
        message: message.content
      )
    else
      Rails.logger.error "Message save failed: #{message.errors.full_messages.join(', ')}"
    end

=======
    # Static roomname: "general"
    room = params[:room] || "general"
    stream_from "chat_channel_#{room}"
  end

  def receive(data)
    if data["message"].present?
      # print, debug, log
      Rails.logger.info "Message received: #{data['message']}"
      # Broadcast the message to room "general"
      room = params[:room] || "general"
      username = current_user
      ActionCable.server.broadcast("chat_channel_#{room}", { username: username, message: data["message"] })
    end
>>>>>>> bd3e9e9115042199b9e47c0ac8507840173daca7
  end
end
