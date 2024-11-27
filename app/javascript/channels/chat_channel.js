import consumer from "channels/consumer";

document.addEventListener('DOMContentLoaded', () => {
  const sendButton = document.getElementById('send-button');
  const messageInput = document.getElementById('message-input');
  const worldId = 1;  // Replace with dynamic world ID (e.g., passed from controller or URL)

  if (sendButton) {
    sendButton.addEventListener('click', sendChatMessage);
  }

  // Connect to the chat channel for the current world
  const chatChannel = consumer.subscriptions.create(
      { channel: "ChatChannel", world_id: worldId },  // Pass the world_id dynamically
      {
        connected() {
          console.log(`Connected to chat channel for world ${worldId}`);
        },

        disconnected() {
          console.log(`Disconnected from chat channel for world ${worldId}`);
        },

        received(data) {
          const messageList = document.getElementById('message-list'); // List of chat messages
          const messageElement = document.createElement('div');
          messageElement.textContent = `${data.username}: ${data.message}`;
          messageList.appendChild(messageElement);
        }
      }
  );

  function sendChatMessage() {
    const message = messageInput.value;
    if (message.trim()) {
      // Send the message to the channel
      chatChannel.send({ message: message });
      messageInput.value = ''; // Clear input field
    }
  }
});
