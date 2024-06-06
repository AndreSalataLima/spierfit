import consumer from "./consumer"

document.addEventListener("turbolinks:load", () => {
  const element = document.getElementById('exercise-set-id')
  if (element) {
    const exerciseSetId = element.getAttribute('data-exercise-set-id')

    consumer.subscriptions.create({ channel: "ExerciseSetsChannel", exercise_set_id: exerciseSetId }, {
      received(data) {
        console.log("Received data:", data)
        // Update your frontend with the new data
        document.getElementById('reps').innerText = data.reps
        document.getElementById('sets').innerText = data.sets
        // Update other fields similarly...
      }
    })
  }
})


// Certifique-se de que sua view que exibe os detalhes do ExerciseSet contém o ID correto para que o JavaScript possa funcionar. Exemplo em sua view (por exemplo, show.html.erb para ExerciseSets):

// erb
// Copy code
// <div id="exercise-set-id" data-exercise-set-id="<%= @exercise_set.id %>">
//   <p id="reps">Reps: <%= @exercise_set.reps %></p>
//   <p id="sets">Sets: <%= @exercise_set.sets %></p>

// </div>
