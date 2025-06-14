class Api::V1::WorkoutsController < Api::V1::BaseController
  before_action :authenticate_user!
  after_action  :verify_policy_scoped, only: [:index]
  after_action  :verify_authorized,     only: [:index, :show, :create, :update]

  def index
    workouts = policy_scope(Workout)
    authorize Workout
    render json: workouts.map { |w| w.slice(
      :id,
      :workout_protocol_id,
      :protocol_day,
      :goal,
      :duration,
      :calories_burned,
      :intensity,
      :completed
    ) }
  end

  def show
    workout = Workout.find(params[:id])
    authorize workout
    render json: workout.slice(
      :id,
      :workout_protocol_id,
      :protocol_day,
      :goal,
      :duration,
      :calories_burned,
      :intensity,
      :completed
    )
  end

  def create
    workout = Workout.new(workout_params)
    workout.user = current_user
    authorize workout

    if workout.save
      render json: workout.slice(
        :id,
        :workout_protocol_id,
        :protocol_day,
        :goal,
        :duration,
        :calories_burned,
        :intensity,
        :completed
      ), status: :created
    else
      render json: { errors: workout.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    workout = Workout.find(params[:id])
    authorize workout

    if workout.update(workout_params)
      render json: workout.slice(
        :id,
        :workout_protocol_id,
        :protocol_day,
        :goal,
        :duration,
        :calories_burned,
        :intensity,
        :completed
      ), status: :ok
    else
      render json: { errors: workout.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def workout_params
    params.permit(
      :workout_protocol_id,
      :protocol_day,
      :goal,
      :duration,
      :calories_burned,
      :intensity,
      :completed
    )
  end
end
