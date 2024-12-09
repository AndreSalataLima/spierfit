// app/javascript/controllers/reps_series_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["reps", "sets"];
  static values = {
    exerciseSetId: Number
  }

  connect() {
    this.seriesActive = false;
    this.timer = setInterval(() => {
      this.updateRepsAndSets();
    }, 1000);
  }

  disconnect() {
    clearInterval(this.timer);
  }

  updateRepsAndSets() {
    fetch(`/exercise_sets/${this.exerciseSetIdValue}/reps_and_sets`)
      .then(response => response.json())
      .then(data => {
        if (this.repsTarget) {
          this.repsTarget.textContent = data.reps;
        }

        if (this.setsTarget) {
          this.setsTarget.textContent = data.sets;
        }

        if (data.in_series && !this.seriesActive) {
          // Series has started
          const seriesStartedEvent = new CustomEvent('series:started');
          document.dispatchEvent(seriesStartedEvent);
          this.seriesActive = true;
        } else if (!data.in_series && this.seriesActive) {
          // Series has ended
          const seriesEndedEvent = new CustomEvent('series:ended');
          document.dispatchEvent(seriesEndedEvent);
          this.seriesActive = false;
        }
      })
      .catch(error => console.error('Error fetching reps and sets:', error));
  }
}
