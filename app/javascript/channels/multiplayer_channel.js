import consumer from "channels/consumer";

const multiplayerChannel = consumer.subscriptions.create("MultiplayerChannel", {
  received(data) {
    // Empty Logic
    console.log("MultiplayerChannel received data:", data);
  },
});

export default multiplayerChannel;
