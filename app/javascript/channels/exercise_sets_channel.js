import consumer from "./consumer"

document.addEventListener("turbo:load", () => {
  const element = document.getElementById('exercise-set-id')
  if (element) {
    const exerciseSetId = element.getAttribute('data-exercise-set-id')

    consumer.subscriptions.create({ channel: "ExerciseSetsChannel", exercise_set_id: exerciseSetId }, {
      received(data) {
        document.getElementById('reps').innerText = data.reps
        document.getElementById('sets').innerText = data.sets
        // Atualize outros campos da mesma maneira
      }
    })
  }
})
