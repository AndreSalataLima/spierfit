class ProtocolExercisesController < ApplicationController

  def new
    @protocol_exercise = ProtocolExercise.new(muscle_group: params[:muscle_group])

    render partial: 'protocol_exercise_fields', locals: { protocol_exercise: @protocol_exercise }, layout: false
  end

  def create
    @workout_protocol = WorkoutProtocol.find(params[:workout_protocol_id])

    # Permitir nested attributes
    permitted = params.require(:workout_protocol).permit(
      protocol_exercises_attributes: [
        :muscle_group, :exercise_id, :sets, :min_repetitions,
        :max_repetitions, :day, :observation
      ]
    )

    # Extrair dados do exercício
    protocol_exercises_attrs = permitted[:protocol_exercises_attributes]
    new_exercise_data = protocol_exercises_attrs.is_a?(Hash) ? protocol_exercises_attrs.values.first : protocol_exercises_attrs.first

    # Criar o novo exercício
    @protocol_exercise = @workout_protocol.protocol_exercises.new(new_exercise_data || {})

    if @protocol_exercise.save
      # Determinar a URL de redirecionamento com base no tipo de usuário
      redirect_path = if personal_signed_in?
                        edit_for_personal_personal_user_workout_protocol_path(
                          current_personal, @workout_protocol.user, @workout_protocol
                        )
                      elsif user_signed_in?
                        edit_for_user_user_workout_protocol_path(@workout_protocol.user, @workout_protocol)
                      else
                        render json: { errors: ['Usuário não autenticado'] }, status: :unauthorized and return
                      end

      render json: { redirect_url: redirect_path }, status: :ok
    else
      render json: { errors: @protocol_exercise.errors.full_messages }, status: :unprocessable_entity
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
