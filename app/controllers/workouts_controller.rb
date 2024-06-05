class WorkoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workout, only: [:show, :edit, :update, :destroy]
  # before_action :set_user, only: [:index, :new, :create]

  def index
    @workouts = current_user.workouts
  end

  def show
    # Workout.find(params[:id])
  end

  def new
    @workout = @user.workouts.build
  end

  def create
    @workout = current_user.workouts.build(workout_params)
    if @workout.save
      redirect_to @workout, notice: 'Workout was successfully created.'
    else
      render :new
    end
  end

  def edit
    @workout
  end

  def update
    if @workout.update(workout_params)
      redirect_to @workout, notice: 'Workout was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @workout.destroy
    redirect_to workouts_url, notice: 'Workout was successfully destroyed.'
  end

  private

  def set_workout
    @workout = Workout.find(params[:id])
  end

  def workout_params
    params.require(:workout).permit(:user_id, :personal_id, :gym_id, :exercise_id, :date, :time, :duration, :intensity, :calories_burned, :notes, :photos, :videos)
  end
end
