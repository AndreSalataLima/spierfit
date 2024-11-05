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
    creation_time = data['creation_time'] || Time.current.iso8601(3)

    # Encontrar a máquina associada a este MAC address
    machine = Machine.find_by(mac_address: mac_address)

    if machine && machine.current_user_id.present?
      # Encontrar o ExerciseSet ativo para esta máquina e usuário
      exercise_set = ExerciseSet.joins(:workout)
                                .where(machine_id: machine.id, completed: false)
                                .where(workouts: { user_id: machine.current_user_id, completed: false })
                                .order(created_at: :desc)
                                .first

      if exercise_set
        # Criar um novo DataPoint associado ao ExerciseSet atual
        data_point = DataPoint.create!(
          value: sensor_value.to_f,
          mac_address: mac_address,
          exercise_set: exercise_set,
          recorded_at: creation_time
        )

        # Transmitir os dados para os clientes inscritos no SensorDataChannel deste ExerciseSet
        SensorDataChannel.broadcast_to(
          exercise_set,
          sensor_value: data_point.value,
          mac_address: data_point.mac_address,
          recorded_at: data_point.recorded_at.iso8601(3)
        )
        Rails.logger.info "Dados transmitidos para o SensorDataChannel do ExerciseSet ID #{exercise_set.id}"
      else
        Rails.logger.warn "Nenhum ExerciseSet ativo encontrado para a máquina com MAC #{mac_address} e usuário #{machine.current_user_id}."
      end
    else
      Rails.logger.warn "Nenhuma máquina encontrada com MAC Address #{mac_address} ou máquina não está em uso."
    end
  end


  def unsubscribed
    Rails.logger.info "Dispositivo desconectado do DeviceDataChannel"
  end
end
