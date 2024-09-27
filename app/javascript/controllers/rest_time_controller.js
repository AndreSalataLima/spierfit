// app/javascript/controllers/rest_time_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value"];
  static values = { exerciseSetId: Number }

  connect() {
    this.restTime = 0;
    this.isSeriesActive = false;

    document.addEventListener('series:started', this.onSeriesStarted.bind(this));
    document.addEventListener('series:ended', this.onSeriesEnded.bind(this));
  }

  disconnect() {
    this.clearTimer();
    document.removeEventListener('series:started', this.onSeriesStarted.bind(this));
    document.removeEventListener('series:ended', this.onSeriesEnded.bind(this));
  }

  onSeriesStarted() {
    this.isSeriesActive = true;
    this.resetRestTime();
  }

  onSeriesEnded() {
    this.isSeriesActive = false;
    this.restTime = 0; // Iniciar em 0 segundos
    this.valueTarget.textContent = `${this.restTime}s`;
    this.startRestTimer();
  }

  startRestTimer() {
    if (this.timer) return; // Prevent multiple timers
    this.timer = setInterval(() => {
      this.restTime += 1;
      this.valueTarget.textContent = `${this.restTime}s`;
      this.updateRestTimeOnServer();
    }, 1000);
  }

  resetRestTime() {
    this.clearTimer();
    this.restTime = 0;
    this.valueTarget.textContent = `${this.restTime}s`;
  }

  updateRestTimeOnServer() {
    fetch(`/exercise_sets/${this.exerciseSetIdValue}/update_rest_time`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").getAttribute("content"),
      },
      body: JSON.stringify({ rest_time: this.restTime }),
    });
  }

  clearTimer() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }
}
