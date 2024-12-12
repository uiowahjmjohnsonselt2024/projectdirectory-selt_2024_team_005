import consumer from "channels/consumer";

let multiplayerChannel = null;

// Function to initialize the MultiplayerChannel subscription
export function initializeMultiplayerChannel(gridId, onPlayerUpdate) {
  if (!gridId) {
    console.error("Grid ID is required to initialize MultiplayerChannel.");
    return;
  }

  // Unsubscribe from any existing channel
  if (multiplayerChannel) {
    multiplayerChannel.unsubscribe();
    multiplayerChannel = null;
  }

  // Subscribe to the MultiplayerChannel for the given grid
  multiplayerChannel = consumer.subscriptions.create(
      { channel: "MultiplayerChannel", grid_id: gridId },
      {
        received(data) {
          console.log("Received multiplayer update:", data);

          // Handle different types of updates
          if (data.type === "player_joined") {
            onPlayerUpdate("joined", data.username, data.cell_id);
          } else if (data.type === "update_position") {
            onPlayerUpdate("moved", data.username, data.cell_id);
          } else if (data.type === "player_left") {
            onPlayerUpdate("left", data.username);
          }
        },
        connected() {
          console.log(`Connected to MultiplayerChannel for grid ${gridId}`);
        },
        disconnected() {
          console.log("Disconnected from MultiplayerChannel.");
        }
      }
  );
}

// Function to update the current player's position
export function updatePlayerPosition(cellId) {
  if (!multiplayerChannel) {
    console.error("MultiplayerChannel is not initialized.");
    return;
  }

  multiplayerChannel.perform("update_position", { cell_id: cellId });
}

// Function to unsubscribe from the MultiplayerChannel
export function unsubscribeMultiplayerChannel() {
  if (multiplayerChannel) {
    multiplayerChannel.unsubscribe();
    multiplayerChannel = null;
    console.log("Unsubscribed from MultiplayerChannel.");
  }
}
