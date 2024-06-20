class ExerciseSetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercise_set, only: [:show, :edit, :update, :destroy, :complete]

  def index
    @exercise_sets = ExerciseSet.all
  end

  def show
  end

  def new
    @exercise_set = ExerciseSet.new
  end

  def create
    @machine = Machine.find(params[:machine_id])
    @workout = current_user.workouts.find_or_create_by!(completed: false) do |workout|
      workout.gym_id = @machine.gym_id
      workout.workout_type = 'General'
      workout.goal = 'Fitness'
    end

    @exercise_set = @workout.exercise_sets.create!(
      exercise_id: params[:exercise_id],
      machine_id: @machine.id,
      reps: 0,
      sets: 0,
      weight: 0,
      duration: 0,
      rest_time: 0,
      intensity: '',
      feedback: '',
      max_reps: 0,
      performance_score: 0,
      effort_level: '',
      energy_consumed: 0
    )

    redirect_to exercise_set_path(@exercise_set)
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

  def complete
    @exercise_set.update(completed: true)
    redirect_to user_index_machines_path, notice: 'Exercise set was successfully completed.'
  end

  private

  def set_exercise_set
    @exercise_set = ExerciseSet.find(params[:id])
  end

  def exercise_set_params
    params.require(:exercise_set).permit(:workout_id, :exercise_id, :machine_id, :reps, :sets, :weight, :duration, :rest_time, :intensity, :feedback, :max_reps, :performance_score, :effort_level, :energy_consumed)
  end
end
