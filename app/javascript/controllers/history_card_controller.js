import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    console.log("History card controller connected:", this.urlValue);
  }

  goToHistory() {
    window.location.href = this.urlValue; // Altere para usar o caminho dinâmico do usuário
  }
}
