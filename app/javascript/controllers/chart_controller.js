import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    data: Array,
    labels: Array,
    chartDataUrl: String
  };

  connect() {
    console.log("ChartController connected");
    this.initializeChart();
    this.startPolling();
  }

  initializeChart() {
    const ctx = this.element.querySelector("canvas").getContext("2d");

    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: this.labelsValue.slice(-40),
        datasets: [
          {
            label: "Sensor Data",
            data: this.dataValue.slice(-40).map(value => Math.abs(value)), // Exibe dados em valor absoluto inicialmente
            borderColor: "rgba(250, 35, 39, 0.5)",
            backgroundColor: "rgba(250, 35, 39, 0.3)",
            fill: true,
            pointRadius: 0,
            tension: 0.8
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
        },
        scales: {
          x: {
            ticks: { display: false }
          },
          y: {
            ticks: { display: false },
            min: 0,
            max: 3000
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
            const creationDate = new Date(latestCreationTime);
            const adjustedCreationDate = new Date(creationDate.getTime() + 10800 * 1000);
            const now = new Date();
            const timeDifference = (now - adjustedCreationDate) / 1000;

            console.log(`Diferença entre criação do dado e visualização: ${timeDifference.toFixed(3)} segundos`);

            // Atualiza o gráfico com valores absolutos
            this.chart.data.labels = newLabels.slice(-40);
            this.chart.data.datasets[0].data = newDataPoints
              .slice(-40)
              .map(value => Math.abs(value));
            this.chart.update();

            lastValue = latestValue;
          }
        } else {
          console.error("Erro ao buscar dados:", response.status);
        }
      } catch (error) {
        console.error("Erro ao atualizar o gráfico:", error);
      }
    }, 1000);
  }
}
