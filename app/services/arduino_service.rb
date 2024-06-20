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
    response = self.class.get("/things/#{thing_id}/properties", @options) # Certifique-se de que a URL está correta
    if response.success?
      Rails.logger.info "Successfully fetched data: #{response.parsed_response}"
      store_data(response.parsed_response)
    else
      Rails.logger.error "Failed to fetch data: #{response.code} - #{response.body}"
    end
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
      },
      headers: { 'Content-Type' => 'application/json' }
    )
    Rails.logger.info "Token response: #{response.body}"
    response.parsed_response['access_token']
  end

  def store_data(data)
    data.each do |datum|
      Rails.logger.info "Storing data: #{datum}"
      ArduinoDatum.create(
        value: datum['last_value'],
        recorded_at: datum['value_updated_at'],
        exercise_set_id: find_exercise_set(datum['thing_id'])
      )
    end
  end

  def find_exercise_set(thing_id)
    # lógica para encontrar o exercise_set correto, possivelmente utilizando `thing_id`
  end
end
