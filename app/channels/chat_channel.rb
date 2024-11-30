class ChatChannel < ApplicationCable::Channel
  def subscribed
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
  end
end
