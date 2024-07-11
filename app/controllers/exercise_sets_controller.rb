class ExerciseSetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercise_set, only: [:show, :edit, :update, :destroy, :complete]

  def show
    @arduino_data = @exercise_set.arduino_data.order(:recorded_at)
    @distance_variation = calculate_distance_variation(@arduino_data)
    @repetitions = calculate_repetitions(@distance_variation)

    duration = calculate_duration(@arduino_data)
    rest_time = calculate_rest_time(@arduino_data)
    sets = calculate_sets(@arduino_data) # Corrigido para calcular sets

    # Atualizar os atributos do ExerciseSet
    @exercise_set.update(
      reps: @repetitions,
      duration: duration,
      rest_time: rest_time,
      sets: sets, # Atualizar sets
      updated_at: Time.now
    )
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

    Rails.logger.info "Workout ID: #{@workout.id}, ExerciseSet ID: #{@exercise_set.id}"

    redirect_to exercise_set_path(@exercise_set)
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

  def calculate_distance_variation(data)
    data.each_cons(2).map { |a, b| b.value - a.value }
  end

  def calculate_repetitions(variations)
    concentric = false
    reps = 0

    variations.each do |variation|
      if variation > 0
        concentric = true
      elsif variation < 0 && concentric
        reps += 1
        concentric = false
      end
    end

    reps
  end


  def calculate_duration(data)
    if data.last
      (data.last.recorded_at - data.first.recorded_at).to_i
    else
      0
    end
  end

  def calculate_rest_time(data)
    rest_time = 0
    in_rest = false
    start_time = nil

    data.each do |datum|
      if datum.value == -55
        unless in_rest
          in_rest = true
          start_time = datum.recorded_at
        end
      else
        if in_rest
          in_rest = false
          rest_time += (datum.recorded_at - start_time).to_i
        end
      end
    end

    rest_time
  end

  def calculate_sets(data)
    sets = 0
    in_set = false

    data.each do |datum|
      if datum.value != -55
        unless in_set
          in_set = true
          sets += 1
        end
      else
        in_set = false
      end
    end

    sets
  end
end
