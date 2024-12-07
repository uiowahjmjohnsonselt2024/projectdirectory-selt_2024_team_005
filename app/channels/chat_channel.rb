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
      username = current_user.character.character_name

      # Save message into database
      Message.create!(
        content: data["message"],
        username: username,
        channel_type: channel_type,
        room_id: room_id
      )

      if channel_type == "world"
        # Broadcast to the world chat
        ActionCable.server.broadcast("world_chat", { username: username, message: data["message"], channel: "world" })
      elsif channel_type == "room" && room_id.present?
        # Broadcast to room chat
        ActionCable.server.broadcast("room_chat_#{room_id}", { username: username, message: data["message"], channel: "room" })
      end
    end
  end

  def load_recent_messages(data)
    maximum_message = 50
    channel_type = params[:channel_type]
    room_id = params[:room_id]

    messages = if channel_type == "world"
                 Message.where(channel_type: "world").order(created_at: :desc).limit(maximum_message)
               elsif channel_type == "room" && room_id.present?
                 Message.where(channel_type: "room", room_id: room_id).order(created_at: :desc).limit(maximum_message)
               else
                 []
               end

    transmit(messages.reverse.map { |msg| { username: msg.username, message: msg.content } })
  end
end
