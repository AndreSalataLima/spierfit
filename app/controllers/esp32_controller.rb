class Esp32Controller < ApplicationController
  protect_from_forgery with: :null_session


  def data_points
    @data_points = DataPoint.all # Certifique-se de que você está definindo @data_points
  end

  def receive_data
    data = JSON.parse(request.body.read)
    distance = data['sensor_value']
    mac_address = data['mac_address']
    creation_time_str = data['creation_time']

    # Converter a string de tempo em um objeto Time
    sensor_time = Time.strptime(creation_time_str, '%Y-%m-%dT%H:%M:%S%z')

    es = current_exercise_set
    if es.nil?
      render json: {status: 'Error', message: 'Nenhum ExerciseSet ativo encontrado'}, status: :bad_request
      return
    end

    data_point = DataPoint.create!(
      value: distance.to_f,
      mac_address: mac_address,
      created_at: sensor_time,
      exercise_set: es
    )

    # Se você utiliza ActionCable ou similares, pode transmitir dados para o frontend
    SensorDataChannel.broadcast_to(
      es,
      sensor_value: data_point.value,
      mac_address: data_point.mac_address,
      recorded_at: data_point.created_at.iso8601(3)
    )

    render json: { status: 'Success', message: 'Data received and processed' }, status: :ok
  rescue StandardError => e
    Rails.logger.error "Error processing data: #{e.message}"
    render json: { status: 'Error', message: e.message }, status: :internal_server_error
  end


  private

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

  def current_exercise_set
    ExerciseSet.where(completed: false).order(created_at: :desc).first
  end


end
