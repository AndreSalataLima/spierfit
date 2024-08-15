import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static values = {
        data: Array,
        labels: Array
    }

    connect() {
        console.log("ChartController connected");

        const ctx = document.getElementById('myChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: this.labelsValue,  // Labels passadas do backend
                datasets: [{
                    label: '',
                    data: this.dataValue,  // Dados passados do backend
                    borderColor: 'rgba(250, 35, 39, 0.5)',  // Cor da borda suavizada. Alterar para '#fa2327' para cor vermelha
                    fill: true,  // Preenche a área abaixo da linha
                    backgroundColor: 'rgba(250, 35, 39, 0.3)',  // Cor de preenchimento
                    pointRadius: 0,  // Remove os pontos do gráfico
                    borderJoinStyle: 'round',  // Arredonda as junções das linhas
                    tension: 0.4,  // Adiciona suavização às curvas das linhas
                    fill: 'start',  // Define que a área sombreada deve começar no início (abaixo da linha)
                }]
            },
            options: {
                responsive: false,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    x: {
                        display: false
                    },
                    y: {
                        display: false,
                        ticks: {
                            suggestedMin: -1100,
                            suggestedMax: -1030
                        }
                    }
                }
            }
        });
    }
}
