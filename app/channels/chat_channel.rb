class ChatChannel < ApplicationCable::Channel
  def subscribed
    # Type: “world” or "room"
    channel_type = params[:channel_type] || "world"
    room_id = params[:room_id] if channel_type == "room" # Chat with players in the same grid

    if channel_type == "world"
      stream_from "world_chat"
      Rails.logger.info "Subscribed to world_chat"
    elsif channel_type == "room" && room_id.present?
      stream_from "room_chat_#{room_id}"
      Rails.logger.info "Subscribed to room_chat_#{room_id}"
    else
      reject
    end
  end

  def receive(data)
    if data["message"].present?
      # print, debug, log
      Rails.logger.info "Message received: #{data['message']}"
      channel_type = params[:channel_type] || "world"
      room_id = params[:room_id]
      username = current_user
      if channel_type == "world"
        # Broadcast to the world chat
        ActionCable.server.broadcast("world_chat", { username: username, message: data["message"], channel: "world" })
      elsif channel_type == "room" && room_id.present?
        # Broadcast to room chat
        ActionCable.server.broadcast("room_chat_#{room_id}", { username: username, message: data["message"], channel: "room" })
      end
    end
  end
end
