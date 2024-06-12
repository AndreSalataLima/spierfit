require 'httparty'

class ArduinoService
  include HTTParty
  base_uri 'https://api2.arduino.cc/iot/v2'

  def initialize
    @options = {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{fetch_token}"
      }
    }
  end

  def fetch_data(thing_id)
    self.class.get("/things/#{thing_id}", @options)
  end

  private

  def fetch_token
    response = HTTParty.post(
      'https://api2.arduino.cc/iot/v1/clients/token',
      body: {
        grant_type: 'client_credentials',
        client_id: ENV['ARDUINO_CLIENT_ID'],
        client_secret: ENV['ARDUINO_CLIENT_SECRET'],
        audience: 'https://api2.arduino.cc/iot'
      }
    )
    response.parsed_response['access_token']
  end
end
