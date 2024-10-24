# app/jobs/fetch_arduino_data_job.rb
class FetchArduinoDataJob < ApplicationJob
  queue_as :default

  def perform
    response = HTTParty.get('http://127.0.0.1:5000/arduino-data')

    if response.success?
      data = response.parsed_response
      store_data(data)
      ActionCable.server.broadcast 'arduino_data_channel', { data: ArduinoDatum.all.as_json }
    else
      Rails.logger.error "Failed to fetch data: #{response.code}"
    end
  end

  private

  def store_data(data)
    current_exercise_set = ExerciseSet.where(completed: false).last

    data.each do |datum|
      if datum['last_value'].is_a?(String)
        values = datum['last_value'].split(',').map(&:to_i)
      else
        values = [datum['last_value']]
      end

      selected_values = [values[0], values[2], values[4], values[6]].compact
      next if selected_values.include?(-55)

      selected_values.each do |value|
        unless ArduinoDatum.exists?(value: value, recorded_at: datum['value_updated_at'], exercise_set_id: current_exercise_set.id)
          ArduinoDatum.create!(
            value: value,
            recorded_at: datum['value_updated_at'],
            exercise_set_id: current_exercise_set.id
          )
          Rails.logger.info "New data saved: Value - #{value}, Time - #{datum['value_updated_at']}"
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to store data: #{e.message}"
  end
end
