class ArduinoCloudService
  include HTTParty
  base_uri 'https://api2.arduino.cc/iot/v2'

  def initialize
    @headers = {
      "Authorization" => "Bearer V8YjaN9Ob9eTUAEMYzSdi6NnhogLYlyz",
      "Content-Type" => "application/json"
    }
  end

  def fetch_device_data(device_id)
    self.class.get("/devices/#{device_id}/properties", headers: @headers)
  end
end
