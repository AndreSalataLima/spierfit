import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ExerciseSetsChannel", exercise_set_id: window.exerciseSetId }, {
  received(data) {
    console.log("Received data:", data);
    // Atualizar os elementos DOM com os novos dados
    const repsElement = document.querySelector('[data-reps-series-target="reps"]');
    const setsElement = document.querySelector('[data-reps-series-target="sets"]');

    if (repsElement) {
      repsElement.textContent = data.reps;
    }

    if (setsElement) {
      setsElement.textContent = data.sets;
    }
  }
});
