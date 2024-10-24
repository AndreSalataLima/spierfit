// app/javascript/controllers/data_processor_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { exerciseSetId: Number }

  connect() {
    this.timer = setInterval(() => {
      this.processNewData();
    }, 10000); // Adjust the interval as needed
  }

  disconnect() {
    clearInterval(this.timer);
  }

  processNewData() {
    fetch(`/exercise_sets/${this.exerciseSetIdValue}/process_new_data`)
      .then(response => response.json())
      .then(data => {
        console.log('Data processed:', data);
        // Optionally, update the UI or handle response data
      })
      .catch(error => console.error('Error processing data:', error));
  }
}
