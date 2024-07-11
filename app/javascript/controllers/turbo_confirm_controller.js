import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("turbo:submit-start", (event) => {
      const form = event.target
      const message = form.dataset.turboConfirm
      if (!message || window.confirm(message)) return
      event.preventDefault()
    })
  }
}
