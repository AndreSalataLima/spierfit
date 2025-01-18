import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown"]

  connect() {
    this.dropdownVisible = false
  }

  onInput() {
    const query = this.inputTarget.value.trim()
    if (!query) {
      this.hideDropdown()
      return
    }
    // Buscar personais via /personals/search?query=...
    this.fetchPersonals(query)
  }

  fetchPersonals(query) {
    const searchUrl = this.element.dataset.gymPersonalFilterSearchUrl; // Nome correto
    const gymId = this.element.dataset.gymPersonalFilterGymId;

    fetch(`${searchUrl}?query=${encodeURIComponent(query)}&gym_id=${gymId}`, {
      headers: { Accept: "application/json" },
    })
      .then((r) => r.json())
      .then((personals) => this.populateDropdown(personals))
      .catch((err) => console.error("Erro ao buscar personais:", err));
  }


  populateDropdown(personals) {
    this.dropdownTarget.innerHTML = ""

    if (personals.length === 0) {
      const li = document.createElement("li")
      li.textContent = "Nenhum personal encontrado."
      li.classList.add("p-2", "text-gray-400")
      this.dropdownTarget.appendChild(li)
      this.showDropdown()
      return
    }

    const title = document.createElement("li")
    title.textContent = "Personais encontrados:"
    title.classList.add("p-2", "text-gray-400", "border-b", "border-gray-600")
    this.dropdownTarget.appendChild(title)

    personals.forEach(personal => {
      const li = document.createElement("li")
      li.classList.add("p-2", "text-white", "hover:bg-[#202020]", "cursor-pointer")
      li.textContent = `${personal.name} (${personal.email})`
      li.addEventListener("click", () => this.onSelectPersonal(personal))
      this.dropdownTarget.appendChild(li)
    })

    this.showDropdown()
  }

  onSelectPersonal(personal) {
    if (!confirm(`Vincular o personal "${personal.name}" à academia?`)) {
      return;
    }

    const gymId = this.element.dataset.gymPersonalFilterGymId;
    const url = `/gyms/${gymId}/personals/${personal.id}/link`;

    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json",
      },
    })
      .then((response) => {
        if (!response.ok) {
          return response.json().then((data) => {
            throw new Error(data.message || "Erro ao vincular personal.");
          });
        }
        return response.json();
      })
      .then((data) => {
        alert(data.message);
        window.location.href = `/gyms/${gymId}/personals`;
      })
      .catch((err) => {
        console.error(err);
        alert(err.message);
      });
  }


  showDropdown() {
    this.dropdownTarget.classList.remove("hidden")
    this.dropdownVisible = true
  }

  hideDropdown() {
    this.dropdownTarget.classList.add("hidden")
    this.dropdownVisible = false
  }
}
