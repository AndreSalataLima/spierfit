// app/javascript/controllers/rest_time_controller.js

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value"];

  connect() {
    this.restTime = parseInt(this.valueTarget.textContent) || 0;
    this.seriesCompleted = this.element.dataset.seriesCompleted === "true";

    if (this.seriesCompleted) {
      this.timer = setInterval(() => {
        this.updateRestTime();
      }, 10000);

      // Adiciona o listener para parar o contador quando a página mudar
      document.addEventListener('turbo:before-visit', () => {
        this.clearTimer();
      });
    }
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

  disconnect() {
    this.clearTimer();
  }

  clearTimer() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }
}
