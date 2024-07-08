// app/javascript/channels/arduino_data_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("ArduinoDataChannel", {
  connected() {
    console.log("Connected to ArduinoDataChannel");
  },

  disconnected() {
    console.log("Disconnected from ArduinoDataChannel");
  },

  received(data) {
    console.log("Received data: ", data);
    if (data.data) {
      const chartData = data.data.map(datum => [new Date(datum.recorded_at), datum.value]);
      const chart = Chartkick.charts["chart-1"];
      if (chart) {
        console.log("Updating chart with new data.");
        chart.updateData(chartData);
      } else {
        console.log("No chart found to update.");
      }
    } else {
      console.log("No data in the received message.");
    }
  }
});
