import consumer from "channels/consumer";

let chatChannel = null;

function subscribeToChannel(channelType, roomName = null) {
  if (chatChannel) {
    chatChannel.unsubscribe();
  }

  chatChannel = consumer.subscriptions.create(
      {channel: "ChatChannel", channel_type: channelType, room_id: roomName},
      {
        received(data) {
          const messagesContainer = document.getElementById("messages");
          if (messagesContainer) {
            if (Array.isArray(data)) {
              // Historical message
              clearMessages();
              data.forEach((msg) => renderMessage(msg, messagesContainer));
            } else {
              // Real-time message
              renderMessage(data, messagesContainer);
            }
            // Automatically scroll to the latest messages
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
          }
        },
        connected() {
          // Load recent messages
          console.log(`Connected to ${channelType} channel`);
          clearMessages();
          chatChannel.perform("load_recent_messages", {}); // Load recent message
        },
        disconnected() {
          console.log("Disconnected from chat channel.");
        },
      }
  );
}

function clearMessages() {
  const messagesContainer = document.getElementById("messages");
  if (messagesContainer) {
    messagesContainer.innerHTML = "";
  }
}

function renderMessage(data, messagesContainer){
  const messageElement = document.createElement("div");
  const usernameElement = document.createElement("span");
  usernameElement.innerText = `${data.username}: `;
  usernameElement.classList.add("username");

  const messageContent = document.createElement("span");
  messageContent.innerText = data.message;

  messageElement.appendChild(usernameElement);
  messageElement.appendChild(messageContent);
  messagesContainer.appendChild(messageElement);
}

document.addEventListener("turbo:load", () => {
  if (!document.body.classList.contains("chat-page")) {
    return;
  }

  const chatForm = document.getElementById("chat-form");
  const chatInput = document.getElementById("chat-input");
  const chatTypeSelector = document.getElementById("chat-type-selector");

  // Initialize as world chat
  subscribeToChannel("world");

  // Change the chat type
  if (chatTypeSelector) {
    chatTypeSelector.addEventListener("change", (event) => {
      const selectedType = event.target.value; // Get chat type that user select
      if (selectedType === "world") {
        subscribeToChannel("world");
      } else if (selectedType === "room") {
        const roomId = document.body.dataset.roomId; // Get roomID
        subscribeToChannel("room", roomId);
      }
    });
  }

  // Send message
  if (chatForm && chatInput) {
    chatForm.addEventListener("submit", (event) => {
      event.preventDefault();
      const message = chatInput.value.trim();
      if (message !== "" && chatChannel) {
        console.log("Sending message:", message);
        chatChannel.send({ message });
        chatInput.value = "";
      }
    });
  } else {
    console.warn("Chat form or input not found.");
  }
});

