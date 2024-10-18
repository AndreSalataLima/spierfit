class SensorDataChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "Client subscribed to SensorDataChannel"
    stream_from "sensor_data_channel"
  end

  def receive(data)
    Rails.logger.info "Received data: #{data.inspect}"
    sensor_value = data['sensor_value']
    mac_address = data['mac_address']

    # Save data to the database
    DataPoint.create(value: sensor_value, mac_address: mac_address)

    # Broadcast data to all subscribers (optional)
    ActionCable.server.broadcast("sensor_data_channel", data)
  end
end
