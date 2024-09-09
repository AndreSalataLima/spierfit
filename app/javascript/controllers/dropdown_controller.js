// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content", "icon"];

  connect() {
    this.resetDropdowns();
  }

  toggle(event) {
    const content = event.currentTarget.nextElementSibling;
    const icon = this.iconTargets[this.contentTargets.indexOf(content)];

    if (content) {
      content.classList.toggle("hidden");
      if (content.classList.contains("hidden")) {
        content.style.maxHeight = null;
        icon.classList.remove('fa-chevron-up');
        icon.classList.add('fa-chevron-down');
      } else {
        content.style.maxHeight = `${content.scrollHeight}px`;
        icon.classList.remove('fa-chevron-down');
        icon.classList.add('fa-chevron-up');
      }
    }
  }

  // Método para fechar todos os dropdowns
  closeAll() {
    this.contentTargets.forEach((content, index) => {
      const icon = this.iconTargets[index];
      content.classList.add("hidden");
      content.style.maxHeight = null;
      icon.classList.remove('fa-chevron-up');
      icon.classList.add('fa-chevron-down');
    });
  }

  // Método para resetar os dropdowns no carregamento inicial
  resetDropdowns() {
    this.contentTargets.forEach((content, index) => {
      const icon = this.iconTargets[index];
      if (index === 0) {
        content.classList.remove('hidden');
        content.style.maxHeight = `${content.scrollHeight}px`;
        icon.classList.remove('fa-chevron-down');
        icon.classList.add('fa-chevron-up');
      } else {
        content.classList.add('hidden');
        content.style.maxHeight = null;
        icon.classList.remove('fa-chevron-up');
        icon.classList.add('fa-chevron-down');
      }
    });
  }
}
