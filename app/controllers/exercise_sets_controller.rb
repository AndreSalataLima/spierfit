class ExerciseSetsController < ApplicationController
  before_action :set_exercise_set, only: [:show, :edit, :update, :destroy]

  def index
    @exercise_sets = ExerciseSet.all
  end

  def show
  end

  def new
    @exercise_set = ExerciseSet.new
  end

  def create
    @exercise_set = ExerciseSet.new(exercise_set_params)
    if @exercise_set.save
      redirect_to @exercise_set, notice: 'Exercise set was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @exercise_set.update(exercise_set_params)
      redirect_to @exercise_set, notice: 'Exercise set was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @exercise_set.destroy
    redirect_to exercise_sets_url, notice: 'Exercise set was successfully destroyed.'
  end

  private

  def set_exercise_set
    @exercise_set = ExerciseSet.find(params[:id])
  end

  def exercise_set_params
    params.require(:exercise_set).permit(:workout_id, :exercise_id, :reps, :sets, :weight, :duration, :rest_time, :intensity, :feedback, :max_reps, :performance_score, :effort_level, :energy_consumed)
  end
end
