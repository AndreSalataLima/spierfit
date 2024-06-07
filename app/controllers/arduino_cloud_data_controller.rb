require 'httparty'

class ArduinoCloudDataController < ApplicationController
  def index
    response = HTTParty.get('http://127.0.0.1:5000/arduino-data')

    if response.success?
      @data = response.parsed_response
    else
      @error = "Erro ao obter dados: #{response.code}"
    end
  end
end
