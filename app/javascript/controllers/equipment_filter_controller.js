import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions", "suggestion"]

  connect() {
    this.suggestionsVisible = false // Inicialmente, as sugestões estão escondidas
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase()

    // Filtrar as sugestões com base no texto digitado
    this.suggestionTargets.forEach(suggestion => {
      const equipmentName = suggestion.dataset.equipmentFilterNameValue
      if (equipmentName.includes(query)) {
        suggestion.classList.remove("hidden")
      } else {
        suggestion.classList.add("hidden")
      }
    })

    // Mostrar ou esconder o container de sugestões
    const hasVisibleSuggestions = this.suggestionTargets.some(suggestion => !suggestion.classList.contains("hidden"))
    if (hasVisibleSuggestions) {
      this.showSuggestions()
    } else {
      this.hideSuggestions()
    }
  }

  selectSuggestion(event) {
    const equipmentName = event.currentTarget.dataset.equipmentFilterNameValue
    this.inputTarget.value = equipmentName
    this.hideSuggestions()
  }

  showSuggestions() {
    this.suggestionsTarget.classList.remove("hidden")
    this.suggestionsVisible = true
  }

  hideSuggestions() {
    this.suggestionsTarget.classList.add("hidden")
    this.suggestionsVisible = false
  }
}
