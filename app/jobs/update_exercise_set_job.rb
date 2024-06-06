class UpdateExerciseSetJob < ApplicationJob
  queue_as :default

  def perform(exercise_set_id, device_id)
    exercise_set = ExerciseSet.find(exercise_set_id)
    service = ArduinoCloudService.new

    loop do
      response = service.fetch_device_data(device_id)
      if response.success?
        data = response.parsed_response
        exercise_set.update(
          reps: data['reps'],
          sets: data['sets'],
          weight: data['weight'],
          duration: data['duration'],
          rest_time: data['rest_time'],
          intensity: data['intensity'],
          feedback: data['feedback'],
          max_reps: data['max_reps'],
          performance_score: data['performance_score'],
          effort_level: data['effort_level'],
          energy_consumed: data['energy_consumed']
        )
        ActionCable.server.broadcast "exercise_sets_#{exercise_set.id}_channel", exercise_set
      else
        Rails.logger.error("Failed to fetch data: #{response.message}")
      end
      sleep 10 # Wait for 10 seconds before fetching data again
    end
  end
end
