import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["reps", "sets"];
  static values = {
    exerciseSetId: Number
  }

  connect() {
    console.log("RepsSeriesController connected");
    this.currentSet = 0; // Armazena o número da série atual
    this.timer = setInterval(() => {
      console.log("Updating reps and sets..."); // Log para verificar o cronômetro
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
          this.repsTarget.textContent = data.reps; // Exibe as repetições da última série
        }

        if (this.setsTarget) {
          this.setsTarget.textContent = data.sets; // Exibe o número da última série
        }

        // Verifica se houve uma mudança no número de séries
        if (this.currentSet !== data.sets) {
          console.log(`Series changed from ${this.currentSet} to ${data.sets}`);
          this.currentSet = data.sets; // Atualiza o número da série atual
          this.resetRestTime(); // Chama o método para resetar o rest_time no frontend
        }
      })
      .catch(error => console.error('Error fetching reps and sets:', error));
  }

  resetRestTime() {
    console.log("Resetting rest_time on series change");

    // Aqui você pode implementar o código que irá resetar o temporizador de rest_time no frontend
    const restTimeController = this.application.getControllerForElementAndIdentifier(document.querySelector('[data-controller="rest-time"]'), "rest-time");

    if (restTimeController) {
      restTimeController.resetRestTime(); // Método que zera o temporizador no controlador rest_time_controller.js
    } else {
      console.error("RestTimeController not found");
    }
  }
}
