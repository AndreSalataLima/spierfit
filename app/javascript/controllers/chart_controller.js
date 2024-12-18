import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    data: Array,
    labels: Array,
    chartDataUrl: String,
    minDistance: Number,
    maxDistance: Number
  };

  connect() {
    console.log("ChartController connected");
    this.initializeChart();
    this.startPolling();
  }

  initializeChart() {
    const ctx = this.element.querySelector("canvas").getContext("2d");

    const minDist = this.minDistanceValue || 400;
    const maxDist = this.maxDistanceValue || 2000;

    // Ajuste a lógica do gráfico conforme necessário, usando minDist e maxDist
    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: this.labelsValue.slice(-40),
        datasets: [{
          label: "Sensor Data",
          data: this.dataValue.slice(-40),
          borderColor: "rgba(250, 35, 39, 0.5)",
          backgroundColor: "rgba(250, 35, 39, 0.3)",
          fill: true,
          pointRadius: 0,
          tension: 0.8
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
        },
        scales: {
          x: { ticks: { display: false } },
          y: {
            ticks: { display: false },
            // Ajuste aqui: por exemplo, se quiser maxDist no topo e minDist em baixo:
            min: 0,
            max: (maxDist - minDist) // Exemplo simples
          }
        },
        animation: false
      }
    });
  }

  startPolling() {
    let lastValue = null;

    setInterval(async () => {
      try {
        const response = await fetch(this.chartDataUrlValue);
        if (response.ok) {
          const html = await response.text();
          const parser = new DOMParser();
          const doc = parser.parseFromString(html, "text/html");

          const newDataPoints = JSON.parse(doc.querySelector("#chart-data").dataset.chartData);
          const newLabels = JSON.parse(doc.querySelector("#chart-data").dataset.chartLabels);
          const creationTimes = JSON.parse(doc.querySelector("#chart-data").dataset.chartCreationTimes);

          const latestValue = newDataPoints[newDataPoints.length - 1];
          const latestCreationTime = creationTimes[creationTimes.length - 1];

          if (latestValue !== lastValue) {
            // Valores mínimos e máximos configurados
            const minDist = this.minDistanceValue || 400;
            const maxDist = this.maxDistanceValue || 2000;

            // Transforma os dados com base nos valores configurados
            const transformedData = newDataPoints.slice(-40).map(value => maxDist - Math.abs(value));

            // Atualiza o gráfico
            this.chart.data.labels = newLabels.slice(-40);
            this.chart.data.datasets[0].data = transformedData;
            this.chart.update();

            lastValue = latestValue;
          }
        } else {
          console.error("Erro ao buscar dados:", response.status);
        }
      } catch (error) {
        console.error("Erro ao atualizar o gráfico:", error);
      }
    }, 200); // Ajuste o intervalo de polling conforme necessário
  }
}
