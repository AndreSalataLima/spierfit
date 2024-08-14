// app/javascript/channels/arduino_data_channel.js
import consumer from "./consumer"

function handleEvent(event, time) {
  const statusElement = document.getElementById('event-status');
  if (event === "pause_started") {
    statusElement.textContent = `Pause started at ${time}`;
  } else if (event === "series_started") {
    statusElement.textContent = `Series started at ${time}`;
  }
}

consumer.subscriptions.create("ArduinoDataChannel", {
  connected() {
    console.log("Connected to ArduinoDataChannel");
  },

  disconnected() {
    console.log("Disconnected from ArduinoDataChannel");
  },

  received(data) {
    console.log("Received data:", data);
    if (data.event) {
      handleEvent(data.event, data.time);
    }
  }
});
