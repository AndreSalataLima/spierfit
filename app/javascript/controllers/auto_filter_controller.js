import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "listContainer"]

  connect() {
    this.dropdownVisible = false
  }

  // Disparado sempre que o usuário digita
  onInput() {
    const query = this.inputTarget.value.trim()
    // 1) Se o usuário apagou tudo, limpamos dropdown e lista
    if (!query) {
      this.hideDropdown()
      // Se quiser restaurar a lista original sem filtro, faça:
      this.filterProtocols("")
      return
    }

    // 2) Buscar alunos para o dropdown
    this.fetchUsers(query)

    // 3) Buscar protocolos para a lista
    this.filterProtocols(query)
  }

  // -------------- Alunos (Dropdown) --------------
  fetchUsers(query) {
    const personalId = this.element.dataset.personalId
    // Rota nova: /personals/:id/autocomplete_users?query=...
    fetch(`/personals/${personalId}/autocomplete_users?query=${encodeURIComponent(query)}`, {
      headers: { Accept: "application/json" }
    })
      .then(r => r.json())
      .then(users => this.populateUsersDropdown(users))
      .catch(err => console.error("Erro ao buscar alunos:", err))
  }

  populateUsersDropdown(users) {
    this.dropdownTarget.innerHTML = ""
    if (users.length === 0) {
      const li = document.createElement("li")
      li.classList.add("p-2", "text-gray-400")
      li.textContent = "Nenhum resultado encontrado"
      this.dropdownTarget.appendChild(li)
      this.showDropdown()
      return
    }
    // Caso haja resultados:
    const title = document.createElement("li")
    title.classList.add("p-2", "text-gray-400", "border-b", "border-gray-600")
    title.textContent = "Alunos:"
    this.dropdownTarget.appendChild(title)

    users.forEach(user => {
      const li = document.createElement("li")
      li.classList.add("p-2", "text-white", "hover:bg-[#202020]", "cursor-pointer")
      li.textContent = user.name
      li.addEventListener("click", () => this.selectUser(user))
      this.dropdownTarget.appendChild(li)
    })
    this.showDropdown()
  }

  // Ao clicar no nome do aluno
  selectUser(user) {
    const personalId = this.element.dataset.personalId
    console.log("==> Clicou em aluno:", user)

    const url = `/personals/${personalId}/filter_protocols?query=${encodeURIComponent(user.name)}`
    console.log("==> fetch:", url)

    fetch(url, { headers: { Accept: "text/html" } })
      .then(r => {
        console.log("==> Resposta filter_protocols status:", r.status)
        return r.text()
      })
      .then(html => {
        console.log("==> HTML partial length:", html.length)
        this.listContainerTarget.innerHTML = html
      })
      .catch(err => console.error("==> Erro:", err))

    // Fecha dropdown
    this.hideDropdown()
    // Preenche o campo de busca
    this.inputTarget.value = user.name
  }


  // -------------- Protocolos (Lista) --------------
  filterProtocols(query) {
    const personalId = this.element.dataset.personalId
    console.log("==> filterProtocols com query =", query, "personalId =", personalId)

    const url = `/personals/${personalId}/filter_protocols?query=${encodeURIComponent(query)}`
    console.log("==> fetch:", url)

    fetch(url)
      .then(r => {
        console.log("==> filter_protocols resposta status:", r.status)
        return r.text()
      })
      .then(html => {
        console.log("==> Recebi HTML parcial, length =", html.length)
        this.listContainerTarget.innerHTML = html
      })
      .catch(err => console.error("==> Erro fetch filterProtocols:", err))
  }


  // -------------- Dropdown Utils --------------
  showDropdown() {
    this.dropdownTarget.classList.remove("hidden")
    this.dropdownVisible = true
  }

  hideDropdown() {
    this.dropdownTarget.classList.add("hidden")
    this.dropdownVisible = false
  }
}
