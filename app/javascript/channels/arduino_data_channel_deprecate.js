import consumer from "./consumer"

// Use `window.chart` defined in `chart_controller.js`
function updateChart(newData) {
  const updateStartTime = new Date().getTime(); // Start time of the update

  if (window.chart) {
    const newLabel = new Date(newData[0]).toLocaleTimeString();
    const newValue = newData[1];

    const numberElements = 100;
    if (window.chart.data.labels.length >= numberElements) {
      window.chart.data.labels.shift();  // Remove the first element if we reach the max number of data points
      window.chart.data.datasets[0].data.shift();
    }

    window.chart.data.labels.push(newLabel);  // Add new time label
    window.chart.data.datasets[0].data.push(newValue);  // Add new value

    window.chart.update();  // Update the chart

    const updateEndTime = new Date().getTime();  // End time of the update
    const delay = updateEndTime - updateStartTime;  // Calculate the delay time
  }
}

consumer.subscriptions.create("SensorDataChannel", {
  received(data) {
    const receiveTime = new Date().getTime(); // Time of data reception

    if (data && data.value && data.recorded_at) {
      // Extract the received data's time and value
      const chartData = [new Date(data.recorded_at), data.value];

      // Original time when the data was created (recorded_at)
      const recordedAtTime = new Date(data.recorded_at).getTime();
      const totalDelayToRender = receiveTime - recordedAtTime; // Total delay from creation to rendering

      // Optionally log the delay
      console.log(`Total delay from data creation to rendering on chart: ${totalDelayToRender} ms`);

      // Update the chart
      updateChart(chartData);
    }
  }
});
