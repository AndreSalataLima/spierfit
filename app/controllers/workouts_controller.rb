class WorkoutsController < ApplicationController
  before_action :set_workout, only: %i[show edit update destroy complete]

  def index
    @workouts = Workout.all
  end

  def show
  end

  def new
    @workout = Workout.new
  end

  def edit
  end

  def create
    @workout = Workout.new(workout_params)

    if @workout.save
      redirect_to @workout, notice: 'Workout was successfully created.'
    else
      render :new
    end
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
    respond_to do |format|
      format.html { redirect_to workouts_url, notice: 'Workout was successfully destroyed.' }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@workout) }
    end
  end

  def complete
    @workout.update(completed: true)
    redirect_to user_index_machines_path, notice: 'Workout was successfully completed.'
  end

  private

  def set_workout
    @workout = Workout.find(params[:id])
  end

  def workout_params
    params.require(:workout).permit(:user_id, :personal_id, :gym_id, :workout_type, :goal, :duration, :calories_burned, :intensity, :feedback, :modifications, :intensity_general, :difficulty_perceived, :performance_score, :auto_adjustments)
  end
end
