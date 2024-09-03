class ArduinoDatum < ApplicationRecord
  belongs_to :exercise_set

  after_create_commit :broadcast_datum, :trigger_reps_and_series_update

  private

  def broadcast_datum
    Rails.logger.info "Broadcasting data for ExerciseSet: #{exercise_set.id}"
    arduino_data = ArduinoDatum.where(exercise_set: exercise_set).order(:recorded_at)
    data_to_broadcast = arduino_data.map { |datum| { id: datum.id, value: datum.value, recorded_at: datum.recorded_at } }
    ActionCable.server.broadcast "arduino_data_channel", { data: data_to_broadcast }
    Rails.logger.info "Broadcasted data: #{data_to_broadcast}"
  rescue StandardError => e
    Rails.logger.error "Error broadcasting data: #{e.message}"
  end

  def trigger_reps_and_series_update
    ExerciseSet.update_reps_and_series(self.exercise_set)
  end
end
