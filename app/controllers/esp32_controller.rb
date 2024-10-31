class Esp32Controller < ApplicationController
  protect_from_forgery with: :null_session


  def data_points
    @data_points = DataPoint.all # Certifique-se de que você está definindo @data_points
  end

  def receive_data
    data = JSON.parse(request.body.read)
    distance = data['sensor_value']
    mac_address = data['mac_address']
    creation_time_str = data['creation_time']  # Timestamp string from ESP32

    # Parse the timestamp into a Time object
    sensor_time = Time.strptime(creation_time_str, '%Y-%m-%dT%H:%M:%S%z')

    # Store data
    data_point = DataPoint.create!(
      value: distance.to_f,
      mac_address: mac_address,
      created_at: sensor_time,
      exercise_set: current_exercise_set
    )

    # Broadcast data to frontend
    SensorDataChannel.broadcast_to(
      current_exercise_set,
      sensor_value: data_point.value,
      mac_address: data_point.mac_address,
      recorded_at: data_point.created_at.iso8601(3)  # Include milliseconds
    )

    render json: { status: 'Success', message: 'Data received and processed' }, status: :ok
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
