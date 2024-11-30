import consumer from "channels/consumer";

const roomName = "general";

const chatChannel = consumer.subscriptions.create(
    { channel: "ChatChannel", room: roomName },
    {
      received(data) {
        const messagesContainer = document.getElementById("messages");
        if (messagesContainer) {
          const messageElement = document.createElement("div");
          const usernameElement = document.createElement("span");
          usernameElement.innerText = `${data.username}: `;
          usernameElement.classList.add("username"); // 添加样式类

          const messageContent = document.createElement("span");
          messageContent.innerText = data.message;

          messageElement.appendChild(usernameElement);
          messageElement.appendChild(messageContent);
          messagesContainer.appendChild(messageElement);
        }
      },
    }
);

document.addEventListener("turbo:load", () => {
  if (!document.body.classList.contains("chat-page")) {
    return;
  }

  const chatForm = document.getElementById("chat-form");
  const chatInput = document.getElementById("chat-input");

  if (chatForm && chatInput) {
    chatForm.addEventListener("submit", (event) => {
      event.preventDefault();
      const message = chatInput.value.trim();
      if (message !== "") {
        console.log("Sending message:", message);
        chatChannel.send({ message });
        chatInput.value = "";
      }
    });
  } else {
    console.warn("Chat form or input not found.");
  }
});

