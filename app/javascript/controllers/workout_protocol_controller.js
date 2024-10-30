// app/javascript/controllers/workout_protocol_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["exercises", "toggleIcon"]

  toggle(event) {
    const exercisesContainer = event.currentTarget.nextElementSibling
    exercisesContainer.classList.toggle("hidden")

    // Alterna o ícone de seta
    const icon = event.currentTarget.querySelector("[data-workout-protocol-target='toggleIcon']")
    icon.classList.toggle("fa-chevron-down")
    icon.classList.toggle("fa-chevron-up")
  }
}
