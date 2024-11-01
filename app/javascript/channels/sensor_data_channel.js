// app/javascript/channels/sensor_data_channel.js
import consumer from "./consumer"

// Use `window.chart` defined in `chart_controller.js`
function updateChart(newData) {
  if (window.chart) {
    const newLabel = new Date(newData[0]).toLocaleTimeString();
    const newValue = newData[1];

    const numberElements = 100;
    if (window.chart.data.labels.length >= numberElements) {
      window.chart.data.labels.shift();
      window.chart.data.datasets[0].data.shift();
    }

    window.chart.data.labels.push(newLabel);
    window.chart.data.datasets[0].data.push(newValue);

    window.chart.update();
  }
}

// Obtenha o `exercise_set_id` a partir do DOM
const exerciseSetElement = document.querySelector('[data-exercise-set-id]');
const exerciseSetId = exerciseSetElement ? exerciseSetElement.dataset.exerciseSetId : null;

if (exerciseSetId) {
  consumer.subscriptions.create(
    { channel: "SensorDataChannel", exercise_set_id: exerciseSetId }, // Passe o `exercise_set_id`
    {
      received(data) {
        if (data && data.sensor_value && data.recorded_at) {
          const generatedTime = new Date(data.recorded_at);
          const displayedTime = new Date();
          const totalTime = ((displayedTime - generatedTime) / 1000).toFixed(3); // seconds with milliseconds

          console.log(`Dado gerado em ${generatedTime.toISOString()}, dado exibido em ${displayedTime.toISOString()}, valor do dado exibido ${data.sensor_value}. Tempo total: ${totalTime} segundos`);

          // Update chart or other UI elements
          const chartData = [data.recorded_at, data.sensor_value];
          updateChart(chartData);
        }
      }
    }
  );
} else {
  console.error("Exercise Set ID not found in the DOM.");
}
