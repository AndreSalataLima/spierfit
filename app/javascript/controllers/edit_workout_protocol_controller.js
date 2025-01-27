// app/javascript/controllers/edit_workout_protocol_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Aqui listamos as "targets" que iremos manipular
  static targets = [
    "protocolModal",                 // O modal em si
    "protocolExerciseFieldsContainer" // Container onde o partial é injetado
  ]

  connect() {
    // Lê o ID do protocolo do data-attribute
    this.workoutProtocolId = this.element.dataset.workoutProtocolId
    console.log("EditWorkoutProtocolController conectado. ID:", this.workoutProtocolId)
  }

  /* ------------------------------------------------
   *  A) Lógica de "toggle" do grupo muscular
   *     (copiada do muscle_group_controller.js)
   * ----------------------------------------------- */
  toggle(event) {
    event.preventDefault()
    const muscleGroupParam = event.currentTarget.dataset.muscleGroup
    const container = document.getElementById(`exercises-${muscleGroupParam}`)

    if (container.classList.contains("hidden")) {
      container.classList.remove("hidden")
      event.currentTarget.textContent = "-"
    } else {
      container.classList.add("hidden")
      event.currentTarget.textContent = "+"
    }
  }

  /* ------------------------------------------------
   *  B) Lógica de abrir modal
   * ----------------------------------------------- */
  openModal(event) {
    event.preventDefault()
    // Pegamos o muscle_group do botão (caso queira filtrar)
    const muscleGroup = event.currentTarget.dataset.muscleGroup
    console.log("Abrindo modal para grupo:", muscleGroup)

    // Mostra o modal
    this.protocolModalTarget.classList.remove("hidden")

    // Limpa o conteúdo anterior do modal
    this.protocolExerciseFieldsContainerTarget.innerHTML = ""

    // Monta a URL para carregar o partial
    // Passando tanto o ID do protocolo quanto o muscle_group
    const url = `/protocol_exercises/new?workout_protocol_id=${this.workoutProtocolId}&muscle_group=${encodeURIComponent(muscleGroup)}`

    // Faz a requisição para carregar o partial
    fetch(url, { headers: { Accept: "text/html" } })
      .then(response => response.text())
      .then(html => {
        this.protocolExerciseFieldsContainerTarget.innerHTML = html
      })
      .catch(error => console.error("Erro ao carregar o formulário do exercício:", error))
  }

  /* ------------------------------------------------
   *  C) Fechar modal
   * ----------------------------------------------- */
  closeModal(event) {
    event.preventDefault()
    this.protocolModalTarget.classList.add("hidden")
  }

  /* ------------------------------------------------
   *  D) Salvar exercício via AJAX
   * ----------------------------------------------- */
  saveExercise(event) {
    event.preventDefault()

    // Coleta os campos do modal
    const inputs = this.protocolExerciseFieldsContainerTarget.querySelectorAll("input, select, textarea")
    const formData = new FormData()

    inputs.forEach(input => {
      formData.append(input.name, input.value)
    })

    // POST para criar o novo ProtocolExercise
    fetch(`/protocol_exercises?workout_protocol_id=${this.workoutProtocolId}`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content")
      },
      body: formData
    })
      .then(response => response.json())
      .then(data => {
        if (data.redirect_url) {
          // Se deu certo, redireciona à página de edição do protocolo
          window.location.href = data.redirect_url
        } else if (data.errors) {
          alert("Erro ao salvar: " + data.errors.join(", "))
        }
      })
      .catch(error => {
        console.error("Erro ao salvar o exercício:", error)
      })
  }
}
