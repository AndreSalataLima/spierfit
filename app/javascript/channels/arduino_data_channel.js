import consumer from "./consumer"

// Usar `window.chart` que foi definido no `chart_controller.js`
function updateChart(chartData) {
  if (window.chart) {
    console.log("Updating chart with new data.");
    // Atualiza os dados do gráfico existente
    window.chart.data.labels = chartData.map(d => new Date(d[0]).toLocaleTimeString()); // Atualiza os labels
    window.chart.data.datasets[0].data = chartData.map(d => d[1]); // Atualiza os dados
    window.chart.update(); // Atualiza o gráfico visualmente sem recriá-lo
  } else {
    console.log("Chart not found. Ensure it's created in chart_controller.js");
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
    console.log("Received data:", JSON.stringify(data, null, 2));
    if (data && data.data) {
      const chartData = data.data.map(datum => [new Date(datum.recorded_at), datum.value]);
      updateChart(chartData);
    } else {
      console.log("No data in the received message.");
    }
  }
});
