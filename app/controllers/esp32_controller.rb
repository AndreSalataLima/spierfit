class Esp32Controller < ApplicationController
  skip_before_action :verify_authenticity_token  # Ignora a verificação CSRF para facilitar o teste

  def register
    ip = params[:ip]
    Rails.logger.info "ESP32 IP registered: #{ip}"
    render json: { status: 'IP received' }, status: :ok
  end

  def receive_data
    sensor_value = params[:sensor_value]
    mac_address = params[:mac_address]  # Captura o endereço MAC enviado
    DataPoint.create(value: sensor_value, mac_address: mac_address)  # Armazena o valor e o MAC
    Rails.logger.info "Data received: #{sensor_value} from MAC: #{mac_address}"
    render json: { status: 'Data saved' }, status: :ok
  end

  def data_points
    @data_points = DataPoint.all
  end
end
