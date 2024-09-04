// app/javascript/controllers/stop_training_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    userId: Number
  }

  connect() {
    this.modal = document.getElementById('confirmationModal');
    console.log('Modal connected', this.modal); // Verifique se o modal está sendo referenciado corretamente
  }

  confirmStop(event) {
    event.preventDefault();
    this.modal.classList.remove('hidden'); // Mostrar o modal
    console.log('Modal should now be visible');
  }

  confirmEndTraining() {
    const userId = this.userIdValue;
    console.log('Confirm end training clicked, userId:', userId); // Verifique se o ID do usuário está correto
    window.location.href = `/users/${userId}/workouts`; // Redirecionamento
    console.log(`Redirecting to /users/${userId}/workouts`);
    this.modal.classList.add('hidden'); // Fechar o modal
  }

  closeModal() {
    this.modal.classList.add('hidden'); // Fechar o modal
  }
}
