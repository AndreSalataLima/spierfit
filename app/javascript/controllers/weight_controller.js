import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value"]

  connect() {
    console.log("Weight controller connected");

    // Ensure `turbo:load` event is listened to, ensuring the DOM is fully loaded
    document.addEventListener('turbo:load', this.initialize.bind(this));
  }

  disconnect() {
    // Remove the event listener when the controller is disconnected
    document.removeEventListener('turbo:load', this.initialize.bind(this));
  }

  initialize() {
    console.log("Weight controller initialized after Turbo load");
    console.log("Value target:", this.valueTarget); // Verify if the target is present
  }

  // Function to handle the increase in weight
  increase() {
    this.adjustWeight(10);  // Increase the weight by 10
  }

  // Function to handle the decrease in weight
  decrease() {
    this.adjustWeight(-10);  // Decrease the weight by 10
  }

  adjustWeight(delta) {
    // Get the current weight value from the display
    let currentValue = Number(this.valueTarget.textContent.replace('kg', ''));

    // Update the frontend display with the new value immediately
    currentValue = Math.max(0, currentValue + delta);  // Prevent weight from going below 0
    this.valueTarget.textContent = `${currentValue}kg`;

    // Send the new weight to the server via PATCH
    fetch(`/exercise_sets/${this.element.dataset.exerciseSetId}/update_weight`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify({ exercise_set: { weight: currentValue } })  // Send the updated weight
    })
    .then(response => {
      if (!response.ok) throw new Error('Network response was not ok');
      return response.json();  // Convert the response to JSON
    })
    .then(data => {
      console.log("Weight updated:", data);

      // Update the frontend display with the value saved on the backend (@exercise_set.weight)
      this.valueTarget.textContent = `${data.weight}kg`;  // Ensure it reflects the correct saved weight

      // Update the last series weight display, if it exists
      const seriesWeightElement = document.querySelector('.last-series-weight');
      if (seriesWeightElement) {
        seriesWeightElement.textContent = `${data.weight}kg`;  // Update the series weight display
      }
    })
    .catch(error => {
      console.error("Error updating weight:", error);  // Log any errors that occur
    });
  }
}
