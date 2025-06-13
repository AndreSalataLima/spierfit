class Api::V1::ProtocolExercisesController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_workout_protocol
  after_action  :verify_policy_scoped, only: [:index]
  after_action  :verify_authorized,     only: [:index, :show, :create, :update, :destroy]

  def index
    exercises = policy_scope(@workout_protocol.protocol_exercises)
    authorize ProtocolExercise
    render json: exercises.as_json(only: [:id, :exercise_id, :muscle_group, :sets, :min_repetitions, :max_repetitions, :day, :observation])
  end

  def show
    exercise = @workout_protocol.protocol_exercises.find(params[:id])
    authorize exercise
    render json: exercise.as_json(only: [:id, :exercise_id, :muscle_group, :sets, :min_repetitions, :max_repetitions, :day, :observation])
  end

  def create
    exercise = @workout_protocol.protocol_exercises.build(protocol_exercise_params)
    authorize exercise
    if exercise.save
      render json: exercise.as_json(only: [:id, :exercise_id, :muscle_group, :sets, :min_repetitions, :max_repetitions, :day, :observation]), status: :created
    else
      render json: { errors: exercise.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    exercise = @workout_protocol.protocol_exercises.find(params[:id])
    authorize exercise
    if exercise.update(protocol_exercise_params)
      render json: exercise.as_json(only: [:id, :exercise_id, :muscle_group, :sets, :min_repetitions, :max_repetitions, :day, :observation]), status: :ok
    else
      render json: { errors: exercise.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    exercise = @workout_protocol.protocol_exercises.find(params[:id])
    authorize exercise
    exercise.destroy
    head :no_content
  end

  private

  def set_workout_protocol
    @workout_protocol = WorkoutProtocol.find(params[:workout_protocol_id])
  end

  def protocol_exercise_params
    params.permit(:exercise_id, :muscle_group, :sets, :min_repetitions, :max_repetitions, :day, :observation)
  end
end
