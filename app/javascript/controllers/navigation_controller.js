import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { exerciseSetId: String };

  connect() {
    this.element.querySelectorAll("button").forEach(button => {
      button.addEventListener("click", async (event) => {
        event.preventDefault();
        await this.markAsComplete();
        window.location.href = button.closest("a").href;
      });
    });
  }

  async markAsComplete() {
    const exerciseSetId = this.exerciseSetIdValue;

    await fetch(`/exercise_sets/${exerciseSetId}/complete`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").getAttribute("content"),
      }
    });
  }
}
