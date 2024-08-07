import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["value"];

  connect() {
    console.log("Weight controller connected");
    this.updateDisplay();
  }

  increase() {
    console.log("Increasing weight");
    this.value += 10;
    this.updateDisplay();
  }

  decrease() {
    console.log("Decreasing weight");
    this.value = Math.max(0, this.value - 10);
    this.updateDisplay();
  }

  updateDisplay() {
    this.valueTargets.forEach((target) => {
      target.textContent = `${this.value}kg`;
    });
  }

  get value() {
    return Number(this.data.get("value"));
  }

  set value(newValue) {
    this.data.set("value", newValue);
  }
}
