class ArduinoDataChannel < ApplicationCable::Channel
  def subscribed
    stream_from "arduino_data_channel" # Subscribe to the channel
  end

  def unsubscribed
  end

end
