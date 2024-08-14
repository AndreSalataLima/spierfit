import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    connect() {
        console.log("ChartController connected");

        const ctx = document.getElementById('myChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],  // Exemplo de labels
                datasets: [{
                    label: '',  // Título removido
                    data: [12, 19, 3, 5, 2, 3],  // Dados de exemplo
                    borderColor: '#fa2327',
                    fill: true,  // Preenche a área abaixo da linha
                    backgroundColor: 'rgba(250, 35, 39, 0.3)',  // Cor de preenchimento
                    pointRadius: 0,  // Remove os pontos do gráfico
                    borderJoinStyle: 'round',  // Arredonda as junções das linhas
                    tension: 0.4  // Adiciona suavização às curvas das linhas
                }]
            },
            options: {
                responsive: false,  // Desativa a responsividade
                maintainAspectRatio: false,  // Não mantém a proporção
                plugins: {
                    legend: {
                        display: false  // Remove a legenda
                    }
                },
                scales: {
                    x: {
                        display: false  // Oculta o eixo X
                    },
                    y: {
                        display: false  // Oculta o eixo Y
                    }
                }
            }
        });
    }
}
