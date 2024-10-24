import { Controller } from "@hotwired/stimulus";

window.chart = null;

export default class extends Controller {
  static values = {
    data: Array,
    labels: Array
  }

  connect() {
    console.log("ChartController connected");

    const ctx = document.getElementById('chart-1').getContext('2d');

    // Verifica se o gráfico já foi criado
    if (!window.chart) {
      // Cria o gráfico apenas se ele ainda não existir
      window.chart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: this.labelsValue,  // Labels passadas do backend
          datasets: [{
            label: '',
            data: this.dataValue,  // Dados passados do backend
            borderColor: 'rgba(250, 35, 39, 0.5)',  // Cor da borda suavizada
            fill: true,
            backgroundColor: 'rgba(250, 35, 39, 0.3)',  // Cor de preenchimento
            pointRadius: 0,  // Remove os pontos do gráfico
            borderJoinStyle: 'round',
            tension: 0.4,  // Adiciona suavização às curvas das linhas
            fill: 'start',
          }]
        },
        options: {
          responsive: false,
          maintainAspectRatio: false,
          plugins: {
            legend: { display: false }
          },
          scales: {
            // x: { display: false },
            // y: { display: false, ticks: { suggestedMin: -1100, suggestedMax: -1030 } }
          }
        }
      });
    }
  }
}
