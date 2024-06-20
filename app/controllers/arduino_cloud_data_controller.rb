class ArduinoCloudDataController < ApplicationController
  def index
    response = HTTParty.get('http://127.0.0.1:5000/arduino-data')

    if response.success?
      @data = response.parsed_response
      Rails.logger.info "Data fetched successfully: #{@data}"
      store_data(@data)
      @stored_data = ArduinoDatum.all
      Rails.logger.info "Stored data in controller: #{@stored_data.inspect}"

      if @stored_data.any?
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @stored_data }
        end
      else
        @error = "Erro ao obter dados."
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: { error: @error }, status: :unprocessable_entity }
        end
      end
    else
      @error = "Erro ao obter dados: #{response.code}"
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: { error: @error }, status: :unprocessable_entity }
      end
    end
  end

  private

  def store_data(data)
    data.each do |datum|
      Rails.logger.info "Storing data: #{datum}"
      ArduinoDatum.create!(
        value: datum['last_value'],
        recorded_at: datum['value_updated_at']
      )
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to store data: #{e.message}"
  end
end
