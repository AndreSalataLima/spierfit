import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["reps", "sets", "weight"];

  updateData(data) {
    this.updateIfChanged(this.repsTarget, data.reps);
    this.updateIfChanged(this.setsTarget, data.sets);
  }

  updateIfChanged(element, newValue) {
    if (element.textContent != newValue.toString()) {
      element.textContent = newValue;
    }
  }
}
