import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Login Stimulus Controller Conectado!");
  }

  showMessage() {
    alert("Redirecionando para o login de atleta...");
  }
}
