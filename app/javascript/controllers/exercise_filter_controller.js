import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "exerciseList", "exerciseItem"]

  filter() {
    const query = this.searchInputTarget.value.toLowerCase()

    // Para cada item (checkbox + label) presente na lista,
    // checamos se o nome do exercício inclui o texto buscado.
    this.exerciseItemTargets.forEach(item => {
      const exerciseName = item.dataset.exerciseFilterNameValue // aqui guardamos o 'name'
      if (exerciseName.includes(query)) {
        item.classList.remove("hidden")
      } else {
        item.classList.add("hidden")
      }
    })
  }
}
