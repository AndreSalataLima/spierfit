# app/channels/arduino_data_channel.rb
class ArduinoDataChannel < ApplicationCable::Channel
  def subscribed
    stream_from "arduino_data_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
