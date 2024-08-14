import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value"]

  connect() {
    console.log("Weight controller connected");
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
    // Atualize o valor do peso no frontend
    currentValue = Math.max(0, currentValue + delta);
    this.valueTarget.textContent = `${currentValue}kg`;
    document.getElementById('fixed-weight').textContent = `${currentValue}kg`;

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
    })
    .catch(error => {
      console.error("Error updating weight:", error);
    });
  }
}
