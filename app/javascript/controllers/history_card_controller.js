import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("History card controller connected");
  }

  goToHistory() {
    window.location.href = "/users/7/workouts"; // Altere para usar o caminho dinâmico do usuário
  }
}
