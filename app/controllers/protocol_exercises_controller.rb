class ProtocolExercisesController < ApplicationController

  def new
    @protocol_exercise = ProtocolExercise.new(muscle_group: params[:muscle_group])

    render partial: 'protocol_exercise_fields', locals: { protocol_exercise: @protocol_exercise }, layout: false
  end

  def create
    @workout_protocol = WorkoutProtocol.find(params[:workout_protocol_id])

    # 1. Permitimos os nested attributes:
    permitted = params.require(:workout_protocol).permit(
      protocol_exercises_attributes: [
        :muscle_group,
        :exercise_id,
        :sets,
        :min_repetitions,
        :max_repetitions,
        :day,
        :observation
      ]
    )

    # 2. O Rails pode armazenar em Hash se há somente 1 item,
    #    ou Array se houver vários. Pegamos o "primeiro" deles:
    protocol_exercises_attrs = permitted[:protocol_exercises_attributes]
    if protocol_exercises_attrs.is_a?(Hash)
      # => se for um Hash com chave "0", "1", etc.
      new_exercise_data = protocol_exercises_attrs.values.first
    elsif protocol_exercises_attrs.is_a?(Array)
      # => se por algum motivo vier em array
      new_exercise_data = protocol_exercises_attrs.first
    end

    # 3. Construímos o novo ProtocolExercise
    @protocol_exercise = @workout_protocol.protocol_exercises.new(new_exercise_data || {})

    if @protocol_exercise.save
      render json: {
        redirect_url: edit_user_workout_protocol_path(
          @workout_protocol.user,
          @workout_protocol
        )
      }, status: :ok
    else
      render json: {
        errors: @protocol_exercise.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def form_builder_for(object)
    ActionView::Helpers::FormBuilder.new("workout_protocol[protocol_exercises_attributes][]", object, self, {})
  end

  def protocol_exercise_params
    params.require(:protocol_exercise).permit(
      :exercise_id, :muscle_group, :sets, :min_repetitions,
      :max_repetitions, :observation, :day
    )
  end

end
