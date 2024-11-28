import consumer from "channels/consumer";

document.addEventListener('DOMContentLoaded', () => {
    const chatContainer = document.getElementById('chat-container');
    const chatBox = document.getElementById("chat-box");
    const sendButton = document.getElementById('send-button');
    const messageInput = document.getElementById('message-input');
    const worldId = chatContainer.dataset.worldId; // Fetch world ID from data attribute

    if (!worldId) {
        console.error("World ID is missing. Cannot connect to chat channel.");
        return;
    }

    if (sendButton) {
        sendButton.addEventListener('click', sendChatMessage);
    }

    // Connect to the chat channel for the current world
    const chatChannel = consumer.subscriptions.create(
        { channel: "ChatChannel", world_id: worldId },  // Pass the dynamic world ID
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
                // Scroll to the latest message
                messageList.scrollTop = messageList.scrollHeight;
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
