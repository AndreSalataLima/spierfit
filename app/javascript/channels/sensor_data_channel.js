import consumer from "./consumer"

consumer.subscriptions.create("SensorDataChannel", {
  connected() {
    console.log("Connected to SensorDataChannel");
  },

  disconnected() {
    console.log("Disconnected from SensorDataChannel");
  },

  received(data) {
    console.log("Received data:", data);
    // Handle the incoming data here
  }
});
