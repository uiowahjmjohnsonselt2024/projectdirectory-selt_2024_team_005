<<<<<<< HEAD
import consumer from "channels/consumer"

// Example: Dynamically set the world_id when a player joins a world
const worldId = 1  // This should be dynamically set, possibly from a server or URL

// Create a subscription to the MultiplayerChannel
consumer.subscriptions.create(
    { channel: "MultiplayerChannel", world_id: worldId },
    {
        // Called when the subscription is ready for use on the server
        connected() {
            console.log(`Connected to MultiplayerChannel for world ${worldId}`);
        },

        // Called when the subscription has been terminated by the server
        disconnected() {
            console.log(`Disconnected from MultiplayerChannel for world ${worldId}`);
        },

        // Called when there's incoming data on the WebSocket for this channel
        received(data) {
            console.log("Received data:", data);
            const chatBox = document.getElementById("chat-box");
            const messageElement = document.createElement("div");
            messageElement.textContent = `${data.username}: ${data.message}`;
            chatBox.appendChild(messageElement);

            // Check if the data is about a player move
            if (data.type === "player_move") {
                updatePlayerPosition(data);
            }
        }
    }
)

// Update the player's position on the grid
function updatePlayerPosition(data) {
    const playerElement = document.getElementById(`player-${data.player_id}`);

    if (playerElement) {
        // Move the player element to the new position
        // playerElement.style.top = `${data.new_position.y}px`;
        // playerElement.style.left = `${data.new_position.x}px`;
    }
}
=======
import consumer from "channels/consumer";

const multiplayerChannel = consumer.subscriptions.create("MultiplayerChannel", {
  received(data) {
    // Empty Logic
    console.log("MultiplayerChannel received data:", data);
  },
});

export default multiplayerChannel;
>>>>>>> bd3e9e9115042199b9e47c0ac8507840173daca7
