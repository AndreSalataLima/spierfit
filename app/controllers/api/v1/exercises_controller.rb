class Api::V1::ExercisesController < Api::V1::BaseController
  before_action :authenticate_user!
  after_action  :verify_policy_scoped, only: [:index]
  after_action  :verify_authorized, only: [:index, :show, :create, :update]

  def index
    exercises = policy_scope(Exercise)
    authorize Exercise
    render json: exercises.map { |ex| ex.slice(:id, :name, :description, :muscle_group).merge(machine_ids: ex.machine_ids) }
  end

  def show
    exercise = Exercise.find(params[:id])
    authorize exercise
    render json: exercise.slice(:id, :name, :description, :muscle_group).merge(machine_ids: exercise.machine_ids)
  end

  def create
    exercise = Exercise.new(exercise_params)
    authorize exercise

    if exercise.save
      render json: exercise.slice(:id, :name, :description, :muscle_group).merge(machine_ids: exercise.machine_ids), status: :created
    else
      render json: { errors: exercise.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    exercise = Exercise.find(params[:id])
    authorize exercise

    if exercise.update(exercise_params)
      render json: exercise.slice(:id, :name, :description, :muscle_group).merge(machine_ids: exercise.machine_ids), status: :ok
    else
      render json: { errors: exercise.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def exercise_params
    params.permit(:name, :description, :muscle_group, machine_ids: [])
  end
end
