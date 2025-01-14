import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["list"];

  connect() {
    this.listVisible = false;
  }

  // Busca usuários no backend com base no texto digitado
  fetchUsers() {
    const query = document.getElementById("user-search").value.trim();

    if (!query) {
      alert("Por favor, insira um nome para buscar.");
      return;
    }

    fetch(`/users/search?query=${encodeURIComponent(query)}`, {
      headers: { Accept: "application/json" },
    })
      .then((response) => response.json())
      .then((data) => this.populateDropdown(data))
      .catch((error) => console.error("Erro ao buscar usuários:", error));
  }

  // Popula o dropdown com os usuários encontrados
  populateDropdown(users) {
    const dropdown = this.listTarget;
    dropdown.innerHTML = ""; // Limpa a lista anterior

    if (users.length === 0) {
      const noResults = document.createElement("li");
      noResults.textContent = "Nenhum usuário encontrado";
      noResults.classList.add("p-2", "text-gray-400");
      dropdown.appendChild(noResults);
      this.showList();
      return;
    }

    users.forEach((user) => {
      const listItem = document.createElement("li");
      listItem.textContent = user.name;
      listItem.dataset.id = user.id;
      listItem.dataset.name = user.name;
      listItem.classList.add(
        "p-2",
        "text-white",
        "hover:bg-[#202020]",
        "cursor-pointer"
      );
      listItem.addEventListener("click", () => this.selectUser(user));
      dropdown.appendChild(listItem);
    });

    this.showList();
  }

  // Seleciona o usuário no dropdown
  selectUser(user) {
    document.getElementById("user-search").value = user.name;
    document.getElementById("selected-user-id").value = user.id;
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
