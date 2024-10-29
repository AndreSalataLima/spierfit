// app/javascript/controllers/muscle_group_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "modalTitle", "exerciseFieldsContainer"]

  // Método para expandir e retrair a lista de exercícios para cada grupo muscular
  toggle(event) {
    const muscleGroup = event.currentTarget.dataset.muscleGroup
    const container = document.getElementById(`exercises-${this.parameterize(muscleGroup)}`)

    if (container.classList.contains('hidden')) {
      container.classList.remove('hidden')
      event.currentTarget.textContent = "-"
    } else {
      container.classList.add('hidden')
      event.currentTarget.textContent = "+"
    }
  }

  // Método para abrir o modal e carregar o formulário para adicionar um novo exercício
  openModal(event) {
    const muscleGroup = event.currentTarget.dataset.muscleGroup;
    this.modalTarget.classList.remove('hidden');
    this.modalTitleTarget.textContent = muscleGroup;
    this.selectedMuscleGroup = muscleGroup;

    // Faz uma requisição para obter o partial do exercício
    fetch(`/protocol_exercises/new?muscle_group=${encodeURIComponent(muscleGroup)}`, {
      headers: {
        'Accept': 'text/html'
      }
    })
      .then(response => response.text())
      .then(html => {
        this.exerciseFieldsContainerTarget.innerHTML = html;
      });
  }

  // Método para fechar o modal e limpar o conteúdo
  closeModal() {
    this.modalTarget.classList.add('hidden')
    this.exerciseFieldsContainerTarget.innerHTML = ''
  }

  saveExercise() {
    // Coleta os campos de entrada dentro do modal
    const inputs = this.exerciseFieldsContainerTarget.querySelectorAll('input, select, textarea')

    // Cria um objeto FormData
    const formData = new FormData()

    inputs.forEach(input => {
      formData.append(input.name, input.value)
    })

    // Cria inputs ocultos e os adiciona ao formulário principal
    const mainForm = this.element.querySelector('form')

    // Cria um contêiner para os novos campos de exercício
    const exerciseFieldsContainer = document.createElement('div')
    exerciseFieldsContainer.classList.add('hidden')

    formData.forEach((value, name) => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = name
      input.value = value
      exerciseFieldsContainer.appendChild(input)
    })

    // Adiciona o contêiner ao formulário principal
    mainForm.appendChild(exerciseFieldsContainer)

    // Fecha o modal
    this.closeModal()

    // Exibe o exercício como um card no grupo muscular correspondente
    this.addExerciseCard(formData)
  }


  addExerciseCard(formData) {
    const muscleGroup = this.selectedMuscleGroup
    const container = document.querySelector(`#exercises-${this.parameterize(muscleGroup)} [data-exercises-container]`)

    const exerciseId = formData.get('workout_protocol[protocol_exercises_attributes][][exercise_id]')
    const day = formData.get('workout_protocol[protocol_exercises_attributes][][day]')

    // Obter o nome do exercício
    this.getExerciseName(exerciseId).then(exerciseName => {
      // Cria o card do exercício
      const card = document.createElement('div')
      card.classList.add('exercise-card', 'bg-[#202020]', 'rounded-lg', 'p-4', 'mb-2', 'flex', 'justify-between', 'items-center')

      const contentDiv = document.createElement('div')
      const nameDiv = document.createElement('div')
      nameDiv.classList.add('text-white', 'font-semibold')
      nameDiv.textContent = exerciseName

      const dayDiv = document.createElement('div')
      dayDiv.classList.add('text-gray-400')
      dayDiv.textContent = `Dia do treino: ${day}`

      contentDiv.appendChild(nameDiv)
      contentDiv.appendChild(dayDiv)

      card.appendChild(contentDiv)

      // Adiciona o card ao container
      container.appendChild(card)
    })
  }

  getExerciseName(exerciseId) {
    return fetch(`/exercises/${exerciseId}.json`)
      .then(response => response.json())
      .then(data => data.name)
  }

  parameterize(string) {
    return string.toLowerCase().replace(/[^a-z0-9]+/g, '-')
  }
}
