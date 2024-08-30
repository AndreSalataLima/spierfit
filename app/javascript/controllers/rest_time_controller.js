// import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value"];

  connect() {
    this.restTime = parseInt(this.valueTarget.textContent) || 0;
    this.seriesCompleted = this.element.dataset.seriesCompleted === "true";

    if (this.seriesCompleted) {
      this.timer = setInterval(() => {
        this.updateRestTime();
      }, 1000);
    }
  }

  updateRestTime() {
    this.restTime += 1;
    this.valueTarget.textContent = `${this.restTime}s`;

    // Ajax call to update the rest_time on the server
    const exerciseSetId = this.element.dataset.exerciseSetId;
    fetch(`/exercise_sets/${exerciseSetId}/update_rest_time`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").getAttribute("content"),
      },
      body: JSON.stringify({ rest_time: this.restTime }),
    })
    .then(response => {
      if (!response.ok) throw new Error('Network response was not ok');
      return response.json();
    })
    .then(data => {
    })
    .catch(error => {
    });
  }

  disconnect() {
    clearInterval(this.timer); // Stop the timer when the controller is disconnected
  }
}
