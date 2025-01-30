import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "seriesContainer"]

  connect() {
  }

  openModal(event) {
    event.preventDefault();
    const exerciseId = event.currentTarget.getAttribute("data-manual-exercise-exercise-id-value");
    document.getElementById("manual_exercise_exercise_id").value = exerciseId;
    this.modalTarget.classList.remove("hidden");
  }



  closeModal(event) {
    event.preventDefault()
    this.modalTarget.classList.add("hidden")
  }

  addSerie(event) {
    event.preventDefault();
    let container = this.seriesContainerTarget;
    // Conta quantas linhas de séries já existem:
    let currentIndex = container.querySelectorAll("div.flex").length;

    // Lembre que a “primeira” série inicia em index=0.
    let newSerieNumber = currentIndex + 1;

    let newSerieHTML = `
      <div class="flex items-center space-x-2 w-full">
        <span class="text-white font-semibold w-5 text-right shrink-0">${newSerieNumber}.</span>
        <input type="number" name="manual[series][${currentIndex}][reps]" placeholder="Reps"
          class="w-20 bg-[#202020] rounded p-2 text-white text-center placeholder-gray-400" />
        <input type="number" name="manual[series][${currentIndex}][weight]" placeholder="kg"
          class="w-20 bg-[#202020] rounded p-2 text-white text-center placeholder-gray-400" />
      </div>
    `;
    container.insertAdjacentHTML("beforeend", newSerieHTML);
  }

}
