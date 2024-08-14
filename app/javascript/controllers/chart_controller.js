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
                    borderColor: '#fa2327',
                    fill: true,
                    backgroundColor: 'rgba(250, 35, 39, 0.3)',
                    pointRadius: 0,
                    borderJoinStyle: 'round',
                    tension: 0.4
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
