class ArduinoCloudDataController < ApplicationController
  protect_from_forgery except: :receive_data  # Desabilita CSRF para receive_data
  before_action :verify_api_token, only: [:receive_data]

  def index
    response = HTTParty.get('http://127.0.0.1:5000/arduino-data')
    Rails.logger.info "Received data from Arduino Cloud: #{response.body}"

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

  def receive_data
    Rails.logger.info "Received data: #{params[:data]}"
    store_data(params[:data])
    render json: { status: 'Success', message: 'Data received and processed' }, status: :ok
  rescue StandardError => e
    Rails.logger.error "Error processing data: #{e.message}"
    render json: { status: 'Error', message: e.message }, status: :internal_server_error
  end

  private

  def store_data(data)
    current_exercise_set = ExerciseSet.where(completed: false).last

    data.each do |datum|
      values = datum['last_value'].to_s.split(',').map(&:to_i)
      selected_values = values.select { |value| value != -55 }

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

  def verify_api_token
    auth_header = request.headers['Authorization']
    token = auth_header.present? ? auth_header.split(' ').last : nil
    Rails.logger.debug "Received token: #{token}"
    unless token == 'TokenSecret'
      Rails.logger.warn "Unauthorized access attempt with token: #{token}"
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
