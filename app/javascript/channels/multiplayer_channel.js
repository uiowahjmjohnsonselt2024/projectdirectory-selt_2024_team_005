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

            // Check if the data is about a player move
            if (data.type === "player_move") {
                updatePlayerPosition(data);
            }
        }
    }
)

// Update the player's position on the grid (client-side logic)
function updatePlayerPosition(data) {
    const playerElement = document.getElementById(`player-${data.player_id}`);

    if (playerElement) {
        // Move the player element to the new position
        playerElement.style.top = `${data.new_position.y}px`;
        playerElement.style.left = `${data.new_position.x}px`;

        // Optionally, display a message about the move
        const messageElement = document.createElement("p");
        messageElement.innerText = `${data.username} moved to ${data.new_position.x}, ${data.new_position.y}`;
        document.getElementById("movement-messages").appendChild(messageElement);
    }
}
