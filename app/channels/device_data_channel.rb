# app/channels/device_data_channel.rb
class DeviceDataChannel < ApplicationCable::Channel
  def subscribed
    stream_from "device_data_channel"
    Rails.logger.info "Dispositivo conectado ao DeviceDataChannel"
  end

  def receive(data)
    Rails.logger.info "Dados recebidos do dispositivo: #{data.inspect}"
    sensor_value = data['sensor_value']
    mac_address = data['mac_address']

    # Encontrar o ExerciseSet atual
    current_exercise_set = ExerciseSet.where(completed: false).order(created_at: :desc).first

    if current_exercise_set
      # Criar um novo DataPoint associado ao ExerciseSet atual
      data_point = DataPoint.create!(
        value: sensor_value.to_f,
        mac_address: mac_address,
        exercise_set: current_exercise_set,
        created_at: Time.current
      )

      # Transmitir os dados para os clientes inscritos no SensorDataChannel
      SensorDataChannel.broadcast_to(
        current_exercise_set,
        sensor_value: data_point.value,
        mac_address: data_point.mac_address,
        recorded_at: data_point.created_at.iso8601(3)
      )
      Rails.logger.info "Dados transmitidos para o SensorDataChannel do ExerciseSet ID #{current_exercise_set.id}"
    else
      Rails.logger.warn "Nenhum ExerciseSet ativo encontrado."
    end
  end

  def unsubscribed
    Rails.logger.info "Dispositivo desconectado do DeviceDataChannel"
  end
end
