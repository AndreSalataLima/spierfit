class ExerciseSetsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "exercise_sets_#{params[:exercise_set_id]}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
