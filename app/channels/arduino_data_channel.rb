class ArduinoDataChannel < ApplicationCable::Channel
  def subscribed
    stream_from "arduino_data_channel"
    Rails.logger.info "User connected to ArduinoDataChannel"
  end

  def unsubscribed
    Rails.logger.info "User disconnected from ArduinoDataChannel"
  end


  private

  # def process_data(distance, timestamp)
  #   current_time = Time.parse(timestamp)

  #   if distance > @distance_threshold
  #     if @pause_start_time.nil?
  #       @pause_start_time = current_time
  #     elsif current_time - @pause_start_time >= 5.seconds
  #       # Confirma início de uma pausa
  #       ActionCable.server.broadcast("arduino_data_channel", { event: "pause_started", time: current_time.iso8601 })
  #       @series_start_time = nil
  #     end
  #   else
  #     if @series_start_time.nil?
  #       @series_start_time = current_time
  #       ActionCable.server.broadcast("arduino_data_channel", { event: "series_started", time: current_time.iso8601 })
  #     end
  #     @pause_start_time = nil
  #   end
  # end
end
