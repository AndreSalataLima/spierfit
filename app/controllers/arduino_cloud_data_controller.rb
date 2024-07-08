# app/controllers/arduino_cloud_data_controller.rb
class ArduinoCloudDataController < ApplicationController
  def index
    response = HTTParty.get('http://127.0.0.1:5000/arduino-data')

    if response.success?
      @data = response.parsed_response
      store_data(@data)
      @stored_data = ArduinoDatum.all

      respond_to do |format|
        format.html
        format.json { render json: @stored_data }
        format.turbo_stream
      end
    else
      @error = "Erro ao obter dados: #{response.code}"
      respond_to do |format|
        format.html
        format.json { render json: { error: @error }, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('arduino_data', partial: 'error', locals: { error: @error }) }
      end
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
        if ArduinoDatum.exists?(value: value, recorded_at: datum['value_updated_at'], exercise_set_id: current_exercise_set.id)
          Rails.logger.info "Duplicate data found: Value - #{value}, Time - #{datum['value_updated_at']}"
        else
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
