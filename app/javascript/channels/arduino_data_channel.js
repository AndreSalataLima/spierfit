import consumer from "./consumer"

// Usar `window.chart` que foi definido no `chart_controller.js`
function updateChart(newData) {
  const updateStartTime = new Date().getTime(); // Tempo de início da atualização

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

    const updateEndTime = new Date().getTime(); // Tempo em que o gráfico foi atualizado
    const delay = updateEndTime - updateStartTime; // Calcula o tempo de delay
  }
}

consumer.subscriptions.create("ArduinoDataChannel", {
  received(data) {
    const receiveTime = new Date().getTime(); // Tempo de recebimento dos dados

    if (data && data.data) {
      // Pegue apenas o último dado recebido
      const lastData = data.data[data.data.length - 1];
      const chartData = [new Date(lastData.recorded_at), lastData.value];

      // Captura o tempo original em que os dados foram criados (recorded_at)
      const recordedAtTime = new Date(lastData.recorded_at).getTime();
      const totalDelayToRender = receiveTime - recordedAtTime; // Tempo total desde a criação até a renderização

      // Exibe apenas o tempo total de delay desde a criação até a renderização
      console.log(`Total delay from data creation (Arduino Cloud) to rendering on chart: ${totalDelayToRender} ms`);

      // Atualiza o gráfico
      updateChart(chartData);
    }
  }
});
