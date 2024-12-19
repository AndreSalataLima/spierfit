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

    const minDist = this.minDistanceValue || 0; // Limite inferior
    const maxDist = this.maxDistanceValue || 2000; // Limite superior

    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: this.labelsValue.slice(-40),
        datasets: [{
          label: "Sensor Data",
          data: this.dataValue.slice(-40).map(value => this.transformValue(value, minDist, maxDist)),
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
            min: 0, // O gráfico é invertido, começa do mínimo relativo
            max: (maxDist - minDist) // A escala é a diferença entre máximo e mínimo
          }
        },
        animation: false
      }
    });
  }

  transformValue(value, minDist, maxDist) {
    // Transforma o valor absoluto e inverte a escala
    const absValue = Math.abs(value);

    // Garante que o valor esteja no intervalo configurado
    if (absValue < minDist) return maxDist - minDist; // Valor menor que o mínimo, no topo
    if (absValue > maxDist) return 0; // Valor maior que o máximo, na base

    return maxDist - absValue; // Inversão do valor, mapeando o topo para valores menores
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
            const minDist = this.minDistanceValue || 0;
            const maxDist = this.maxDistanceValue || 2000;

            const creationDate = new Date(latestCreationTime);
            const now = new Date();
            const timeDifference = (now - creationDate) / 1000;

            console.log(`Dado gerado em ${creationDate.toISOString()}, ` +
                        `dado exibido em ${now.toISOString()}, ` +
                        `valor do dado exibido ${latestValue}. ` +
                        `Tempo total: ${timeDifference.toFixed(3)} segundos`);

            const transformedData = newDataPoints.slice(-40).map(value => this.transformValue(value, minDist, maxDist));

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
