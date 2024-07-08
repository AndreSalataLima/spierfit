class ArduinoDatum < ApplicationRecord
  belongs_to :exercise_set

  after_create_commit :broadcast_datum

  private

  def broadcast_datum
    Rails.logger.info "Broadcasting data for ExerciseSet: #{exercise_set.id}"
    arduino_data = ArduinoDatum.where(exercise_set: exercise_set).order(:recorded_at)
    broadcast_replace_to "arduino_data_channel",
                         target: "arduino_data",
                         partial: "exercise_sets/arduino_data",
                         locals: { arduino_data: arduino_data }
  end
end
