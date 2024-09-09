class ExerciseSetsChannel < ApplicationCable::Channel
  def subscribed
    if params[:exercise_set_id].present?
      stream_from "exercise_sets_#{params[:exercise_set_id]}_channel"
      Rails.logger.info "Subscribed to exercise_sets_#{params[:exercise_set_id]}_channel"
    else
      Rails.logger.error "No exercise_set_id provided in subscription"
    end
  end

  def unsubscribed
    # Cleanup when channel is unsubscribed
  end
end
