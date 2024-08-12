// app/javascript/controllers/weight_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value"]

  connect() {
    console.log("Weight controller connected");
  }

  increase() {
    let currentValue = Number(this.valueTarget.textContent.replace('kg', ''));
    currentValue += 10;
    this.valueTarget.textContent = `${currentValue}kg`;
    console.log("Increased to:", currentValue);
  }

  decrease() {
    let currentValue = Number(this.valueTarget.textContent.replace('kg', ''));
    currentValue = Math.max(0, currentValue - 10);
    this.valueTarget.textContent = `${currentValue}kg`;
    console.log("Decreased to:", currentValue);
  }
}
