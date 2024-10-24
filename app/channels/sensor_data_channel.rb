# app/channels/sensor_data_channel.rb
class SensorDataChannel < ApplicationCable::Channel
  def subscribed
    # Clientes precisam de um `exercise_set_id` para se inscrever no canal
    if params[:exercise_set_id].present?
      @exercise_set = ExerciseSet.find_by(id: params[:exercise_set_id])

      if @exercise_set
        stream_for @exercise_set
        Rails.logger.info "Cliente inscrito no SensorDataChannel para ExerciseSet ID: #{@exercise_set.id}"
      else
        reject
        Rails.logger.warn "Assinatura rejeitada: ExerciseSet ID #{params[:exercise_set_id]} não encontrado"
      end
    else
      reject
      Rails.logger.warn "Assinatura rejeitada: Nenhum exercise_set_id fornecido"
    end
  end

  def unsubscribed
    Rails.logger.info "Cliente desconectado do SensorDataChannel"
  end
end
