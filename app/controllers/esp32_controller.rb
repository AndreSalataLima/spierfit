class Esp32Controller < ApplicationController
  skip_before_action :verify_authenticity_token  # Ignora a verificação CSRF para facilitar o teste

  def register
    ip = params[:ip]
    Rails.logger.info "ESP32 IP registered: #{ip}"
    render json: { status: 'IP received' }, status: :ok
  end

  def data_points
    @data_points = DataPoint.all
  end
end
