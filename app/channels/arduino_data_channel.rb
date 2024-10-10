class ArduinoDataChannel < ApplicationCable::Channel
  def subscribed
    stream_from "arduino_data_channel" # Subscribe to the channel
    Rails.logger.info "User connected to ArduinoDataChannel"
  end

  def unsubscribed
    Rails.logger.info "User disconnected from ArduinoDataChannel"
  end

end
