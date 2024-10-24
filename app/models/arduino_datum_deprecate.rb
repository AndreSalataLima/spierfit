class ArduinoDatum < ApplicationRecord
  belongs_to :exercise_set

  after_create_commit :broadcast_datum # Callback to broadcast data to the client

  private

  def broadcast_datum
    Rails.logger.info "Broadcasting data for ExerciseSet: #{exercise_set.id}"
    arduino_data = ArduinoDatum.where(exercise_set: exercise_set).order(:recorded_at) # Get all data for the ExerciseSet
    data_to_broadcast = arduino_data.map { |datum| { id: datum.id, value: datum.value, recorded_at: datum.recorded_at } } # Prepare data to broadcast
    ActionCable.server.broadcast "arduino_data_channel", { data: data_to_broadcast } # Broadcast data to the client
    Rails.logger.info "Broadcasted data: #{data_to_broadcast}"
  rescue StandardError => e
    Rails.logger.error "Error broadcasting data: #{e.message}"
  end
end
