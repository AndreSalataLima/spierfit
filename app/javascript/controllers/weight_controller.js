import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value"]

  connect() {
    // Escutar o evento `turbo:load` para garantir que o DOM esteja completamente carregado
    document.addEventListener('turbo:load', this.initialize.bind(this));
  }

  disconnect() {
    // Remover o event listener quando o controlador for desconectado
    document.removeEventListener('turbo:load', this.initialize.bind(this));
  }

  initialize() {
    console.log("Weight controller initialized after Turbo load");
    console.log("Value target:", this.valueTarget); // Verificar se o target está presente

    // Adicionar sua lógica aqui, por exemplo, atualizações de peso
  }

  increase() {
    this.adjustWeight(10);
  }

  decrease() {
    this.adjustWeight(-10);
  }

  adjustWeight(delta) {
    // Obtenha o valor atual do peso
    let currentValue = Number(this.valueTarget.textContent.replace('kg', ''));
    // Atualize o valor do peso no frontend temporariamente
    currentValue = Math.max(0, currentValue + delta);
    this.valueTarget.textContent = `${currentValue}kg`;

    // Enviar o novo peso para o servidor via PATCH
    fetch(`/exercise_sets/${this.element.dataset.exerciseSetId}/update_weight`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify({ exercise_set: { weight: currentValue } })
    })
    .then(response => {
      if (!response.ok) throw new Error('Network response was not ok');
      return response.json();
    })
    .then(data => {
      console.log("Weight updated:", data);

      // Atualize o valor com o peso realmente salvo no servidor (@exercise_set.weight)
      this.valueTarget.textContent = `${data.weight}kg`;

      // Atualizar o valor mostrado na div de `last_series_details["weight"]`
      const seriesWeightElement = document.querySelector('.last-series-weight');
      if (seriesWeightElement) {
        seriesWeightElement.textContent = `${data.weight}kg`;
      }
    })
    .catch(error => {
      console.error("Error updating weight:", error);
    });
  }

}
