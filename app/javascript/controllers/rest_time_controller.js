import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value"];

  connect() {
    console.log("Rest_time controller connected");

    this.restTime = parseInt(this.valueTarget.textContent) || 0;
    this.seriesCompleted = this.element.dataset.seriesCompleted === "true";

    // Inicia o timer se a série foi completada
    if (this.seriesCompleted) {
      this.startRestTimer();
    }

    // Listener para parar o contador quando a página mudar
    document.addEventListener('turbo:before-visit', () => {
      this.clearTimer();
    });
  }

  startRestTimer() {
    this.timer = setInterval(() => {
      this.updateRestTime();
    }, 1000);
  }

  updateRestTime() {
    this.restTime += 1;
    this.valueTarget.textContent = `${this.restTime}s`;

    const exerciseSetId = this.element.dataset.exerciseSetId;
    fetch(`/exercise_sets/${exerciseSetId}/update_rest_time`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").getAttribute("content"),
      },
      body: JSON.stringify({ rest_time: this.restTime }),
    });
  }

  resetRestTime() {
    console.log("Rest timer reset to 0");
    this.clearTimer(); // Para o temporizador atual
    this.restTime = 0; // Reseta o valor de rest_time
    this.valueTarget.textContent = `${this.restTime}s`; // Atualiza o display

    // Opcional: Reiniciar o temporizador se necessário
    this.startRestTimer();
  }

  disconnect() {
    this.clearTimer();
  }

  clearTimer() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }
}
