import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["list"];

  connect() {
    this.listVisible = false;
  }

  // Filtra os usuários com base no texto digitado
  filter(event) {
    const query = event.target.value.toLowerCase();

    if (query.trim() === "") {
      this.hideList();
      return;
    }

    const items = this.listTarget.querySelectorAll("li");
    let hasVisibleItems = false;

    items.forEach((item) => {
      const name = item.dataset.name.toLowerCase();
      if (name.includes(query)) {
        item.classList.remove("hidden");
        hasVisibleItems = true;
      } else {
        item.classList.add("hidden");
      }
    });

    if (hasVisibleItems) {
      this.showList();
    } else {
      this.hideList();
    }
  }

  // Seleciona o usuário no dropdown
  select(event) {
    const userId = event.currentTarget.dataset.id;
    const userName = event.currentTarget.dataset.name;

    // Atualiza o campo de busca com o nome do usuário selecionado
    this.element.querySelector("#user-search").value = userName;

    // Armazena o ID do usuário selecionado no campo oculto
    this.element.querySelector("#selected-user-id").value = userId;

    this.hideList();
  }

  // Mostra a lista
  showList() {
    this.listTarget.classList.remove("hidden");
    this.listVisible = true;
  }

  // Esconde a lista
  hideList() {
    this.listTarget.classList.add("hidden");
    this.listVisible = false;
  }
}
