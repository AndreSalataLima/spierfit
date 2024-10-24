class Esp32Controller < ApplicationController
  protect_from_forgery with: :null_session


  def data_points
    @data_points = DataPoint.all # Certifique-se de que você está definindo @data_points
  end

  def receive_data
    # Assuming data comes in as JSON with 'distance' and 'mac_address'
    data = JSON.parse(request.body.read)
    distance = data['distance']
    mac_address = data['mac_address']
    timestamp = Time.current

    # Process and store data
    data_point = store_data(distance, mac_address, timestamp)

    # Broadcast the data to connected clients
    broadcast_data(data_point)

    render json: { status: 'Success', message: 'Data received and processed' }, status: :ok
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parse error: #{e.message}"
    render json: { status: 'Error', message: 'Invalid JSON format' }, status: :bad_request
  rescue StandardError => e
    Rails.logger.error "Error processing data: #{e.message}"
    render json: { status: 'Error', message: e.message }, status: :internal_server_error
  end

  private

  def store_data(distance, mac_address, timestamp)
    # Find or create the current exercise set
    current_exercise_set = ExerciseSet.where(completed: false).order(created_at: :desc).first

    # Adjust according to your data model
    DataPoint.create!(
      value: distance,
      mac_address: mac_address,
      created_at: timestamp,
      exercise_set: current_exercise_set
    )
  end

  def broadcast_data(data_point)
    exercise_set = data_point.exercise_set

    if exercise_set
      # Broadcast to clients subscribed to this exercise_set
      SensorDataChannel.broadcast_to(
        exercise_set,
        sensor_value: data_point.value,
        mac_address: data_point.mac_address,
        recorded_at: data_point.created_at.iso8601(3) # Include milliseconds
      )
    else
      # Optionally, handle cases where there's no active exercise set
      Rails.logger.warn "DataPoint #{data_point.id} has no associated ExerciseSet."
    end
  end
end
