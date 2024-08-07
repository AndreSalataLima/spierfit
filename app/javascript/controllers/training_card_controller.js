// app/javascript/controllers/training_card_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    console.log("Training card controller connected with URL:", this.urlValue);
  }

  goToTraining() {
    window.location.href = this.urlValue; // Direciona diretamente para o URL armazenado
  }
}
