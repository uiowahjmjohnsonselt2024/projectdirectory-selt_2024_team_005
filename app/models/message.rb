class Message < ApplicationRecord

  after_create :limit_user_messages

  private

  def limit_user_messages
    # Find user's message and sort it by creation time
    user_messages = Message.where(username: username).order(created_at: :desc)

    # If there are more than 100 messages, delete the redundant ones
    if user_messages.count > 100
      messages_to_delete = user_messages.offset(100)
      Message.where(id: messages_to_delete.pluck(:id)).delete_all
    end
  end
end
