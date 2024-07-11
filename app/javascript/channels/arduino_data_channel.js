import consumer from "./consumer"

// Ensure updateChart is defined in the same scope as the subscription.
function updateChart(chartData) {
  const chart = Chartkick.charts["chart-1"];
  if (chart) {
    console.log("Updating chart with new data.");
    chart.updateData(chartData);
  } else {
    console.log("No chart found to update.");
  }
}

// Create a subscription to the ArduinoDataChannel
consumer.subscriptions.create("ArduinoDataChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to ArduinoDataChannel");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("Disconnected from ArduinoDataChannel");
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log("Received data:", JSON.stringify(data, null, 2));
    if (data && data.data) {
      console.log("Data is present, updating chart...");
      // Assuming data.data is an array of { recorded_at, value } objects
      const chartData = data.data.map(datum => [new Date(datum.recorded_at), datum.value]);
      updateChart(chartData);
    } else {
      console.log("No data in the received message.");
    }
  }
});
