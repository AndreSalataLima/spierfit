class Api::V1::ExerciseSetsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_workout
  after_action  :verify_authorized, only: [:show, :create, :update]

  def show
    exercise_set = @workout.exercise_sets.find(params[:id])
    authorize exercise_set
    render json: exercise_set.slice(
      :id,
      :workout_id,
      :exercise_id,
      :sets,
      :reps,
      :weight,
      :duration,
      :rest_time,
      :intensity,
      :feedback,
      :completed
    )
  end

  def create
    exercise_set = @workout.exercise_sets.new(exercise_set_params)
    authorize exercise_set

    if exercise_set.save
      render json: exercise_set.slice(
        :id,
        :workout_id,
        :exercise_id,
        :sets,
        :reps,
        :weight,
        :duration,
        :rest_time,
        :intensity,
        :feedback,
        :completed
      ), status: :created
    else
      render json: { errors: exercise_set.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    exercise_set = @workout.exercise_sets.find(params[:id])
    authorize exercise_set

    if exercise_set.update(exercise_set_params)
      render json: exercise_set.slice(
        :id,
        :workout_id,
        :exercise_id,
        :sets,
        :reps,
        :weight,
        :duration,
        :rest_time,
        :intensity,
        :feedback,
        :completed
      ), status: :ok
    else
      render json: { errors: exercise_set.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_workout
    @workout = Workout.find(params[:workout_id])
  end

  def exercise_set_params
    params.permit(
      :exercise_id,
      :sets,
      :reps,
      :weight,
      :duration,
      :rest_time,
      :intensity,
      :feedback,
      :completed
    )
  end
end
