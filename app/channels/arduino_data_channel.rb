# app/channels/arduino_data_channel.rb
class ArduinoDataChannel < ApplicationCable::Channel
  def subscribed
    stream_from "arduino_data_channel"
    @pause_start_time = nil
    @series_start_time = Time.current
    @distance_threshold = -100 # Valor exemplo para início de pausa
  end

  def receive(data)
    process_data(data["distance"], data["time"])
  end

  private

  def process_data(distance, timestamp)
    current_time = Time.parse(timestamp)

    if distance > @distance_threshold
      if @pause_start_time.nil?
        @pause_start_time = current_time
      elsif current_time - @pause_start_time >= 5.seconds
        # Confirma início de uma pausa
        ActionCable.server.broadcast("arduino_data_channel", { event: "pause_started", time: current_time.iso8601 })
        @series_start_time = nil
      end
    else
      if @series_start_time.nil?
        @series_start_time = current_time
        ActionCable.server.broadcast("arduino_data_channel", { event: "series_started", time: current_time.iso8601 })
      end
      @pause_start_time = nil
    end
  end
end
