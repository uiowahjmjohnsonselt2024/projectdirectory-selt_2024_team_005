// app/javascript/channels/multiplayer_channel.js

import consumer from "channels/consumer"

const worldId = 1  // Example, dynamically set this based on the world the player joins

// Create a subscription to the MultiplayerChannel
consumer.subscriptions.create(
    { channel: "MultiplayerChannel", world_id: worldId },  // Passing the world_id as a parameter
    {
      // Called when the subscription is ready for use on the server
      connected() {
        console.log(`Connected to MultiplayerChannel for world ${worldId}`)
      },

      // Called when the subscription has been terminated by the server
      disconnected() {
        console.log(`Disconnected from MultiplayerChannel for world ${worldId}`)
      },

      // Called when there's incoming data on the WebSocket for this channel
      received(data) {
        console.log("Received data:", data)
        // Handle the received data (e.g., update the grid, player status, etc.)
      }
    }
)
