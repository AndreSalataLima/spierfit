import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["reps", "sets"];
  static values = {
    exerciseSetId: Number
  }

  connect() {
    console.log("RepsSeriesController connected");
    this.updateRepsAndSets(); // Atualiza imediatamente ao conectar
    this.timer = setInterval(() => {
      console.log("Updating reps and sets...");
      this.updateRepsAndSets(); // Atualiza a cada segundo
    }, 1000);
  }

  disconnect() {
    clearInterval(this.timer); // Para o timer quando o controller é desconectado
  }

  updateRepsAndSets() {
    fetch(`/exercise_sets/${this.exerciseSetIdValue}/reps_and_sets`)
      .then(response => response.json())
      .then(data => {
        console.log("Fetched data:", data);

        if (this.repsTarget) {
          this.repsTarget.textContent = data.reps;
        }

        if (this.setsTarget) {
          this.setsTarget.textContent = data.sets;
        }
      })
      .catch(error => console.error('Error fetching reps and sets:', error));
  }



}
