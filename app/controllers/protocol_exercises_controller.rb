class ProtocolExercisesController < ApplicationController

  def new
    @protocol_exercise = ProtocolExercise.new(muscle_group: params[:muscle_group])

    render partial: 'protocol_exercise_fields', locals: { protocol_exercise: @protocol_exercise }, layout: false
  end

  private

  def form_builder_for(object)
    ActionView::Helpers::FormBuilder.new("workout_protocol[protocol_exercises_attributes][]", object, self, {})
  end

end
