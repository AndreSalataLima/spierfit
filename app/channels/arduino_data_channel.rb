# app/channels/arduino_data_channel.rb
class ArduinoDataChannel < ApplicationCable::Channel
  def subscribed
    stream_from "arduino_data_channel"
  end

  def send_data_test
    ActionCable.server.broadcast("arduino_data_channel", { data: { test: "This is a test message from server." } })
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
