class DataPoint < ApplicationRecord
  belongs_to :exercise_set, optional: true

  after_create_commit :broadcast_data_point

  private

  def broadcast_data_point
    Rails.logger.info "Broadcasting data for ExerciseSet: #{exercise_set&.id || 'No ExerciseSet'}"
    data_points = DataPoint.where(exercise_set: exercise_set).order(:recorded_at)
    data_to_broadcast = data_points.map do |datum|
      {
        id: datum.id,
        value: datum.value,
        create_at: datum.recorded_at
      }
    end
    ActionCable.server.broadcast "sensor_data_channel", { data: data_to_broadcast }
    Rails.logger.info "Broadcasted data: #{data_to_broadcast}"
  rescue StandardError => e
    Rails.logger.error "Error broadcasting data: #{e.message}"
  end
end
