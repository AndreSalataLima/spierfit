class DataPoint < ApplicationRecord
  belongs_to :exercise_set, optional: true

  after_create_commit :broadcast_data_point

  private

  def broadcast_data_point
    data_points = DataPoint.where(exercise_set: exercise_set).order(:recorded_at)
    data_to_broadcast = data_points.map do |datum|
      {
        id: datum.id,
        value: datum.value,
        create_at: datum.recorded_at
      }
    end
  rescue StandardError => e
    Rails.logger.error "Error broadcasting data: #{e.message}"
  end
end
