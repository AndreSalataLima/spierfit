class DataPoint < ApplicationRecord
  belongs_to :exercise_set, optional: true

  validates :value, presence: true
  validates :mac_address, presence: true

  after_create_commit :broadcast_data_point

  private

  def broadcast_data_point
    broadcast_append_to "data_points", partial: "esp32/data_point", locals: { data_point: self }, target: "data_points"
  rescue StandardError => e
    Rails.logger.error "Error broadcasting data: #{e.message}"
  end
end
