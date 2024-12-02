import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    data: Array,
    labels: Array,
    chartDataUrl: String // Nova propriedade para a URL de dados do gráfico
  };

  connect() {
    console.log("ChartController connected");

    this.initializeChart();
    this.startPolling(); // Inicia o polling
  }

  initializeChart() {
    const ctx = this.element.querySelector("canvas").getContext("2d");

    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: this.labelsValue.slice(-40), // Apenas os últimos 40 rótulos
        datasets: [
          {
            label: "Sensor Data",
            data: this.invertValues(this.dataValue.slice(-40)), // Apenas os últimos 40 valores invertidos
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
            ticks: { display: false } // Ocultar números do eixo X
          },
          y: {
            ticks: { display: false }, // Ocultar números do eixo Y
            min: 1650, // Limite inferior fixo do eixo Y
            max: 500  // Limite superior fixo do eixo Y
          }
        },
        animation: false // Desativa completamente as animações
      }
    });
  }




  invertValues(data) {
    // Inverte os valores (positivo vira negativo e vice-versa)
    return data.map(value => -value);
  }

  startPolling() {
    let lastValue = null; // Armazena o último valor adicionado ao gráfico

    setInterval(async () => {
      try {
        const response = await fetch(this.chartDataUrlValue);
        if (response.ok) {
          const html = await response.text();
          const parser = new DOMParser();
          const doc = parser.parseFromString(html, "text/html");

          // Extrair dados do novo HTML gerado
          const newDataPoints = JSON.parse(doc.querySelector("#chart-data").dataset.chartData);
          const newLabels = JSON.parse(doc.querySelector("#chart-data").dataset.chartLabels);

          // Verificar se o último valor é diferente do anterior
          const latestValue = newDataPoints[newDataPoints.length - 1];
          if (latestValue !== lastValue) {
            // Atualizar o gráfico apenas se o novo valor for diferente
            this.chart.data.labels = newLabels.slice(-40); // Últimos 40 rótulos
            this.chart.data.datasets[0].data = this.invertValues(newDataPoints.slice(-40)); // Últimos 40 valores invertidos
            this.chart.update();

            lastValue = latestValue; // Atualiza o último valor registrado
          }
        } else {
          console.error("Erro ao buscar dados:", response.status);
        }
      } catch (error) {
        console.error("Erro ao atualizar o gráfico:", error);
      }
    }, 400); // Atualiza a cada 300ms
  }





}
