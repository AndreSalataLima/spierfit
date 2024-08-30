class ExerciseSetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercise_set, only: [:show, :edit, :update, :destroy, :complete, :update_weight]

  def show
    @arduino_data = @exercise_set.arduino_data.order(:recorded_at)

    # Detect series and repetitions using the updated logic
    results = detect_series_and_reps(@arduino_data.map(&:value))

    duration = calculate_duration(@arduino_data)

    # Update the exercise set with the detected number of series and repetitions
    @exercise_set.update(
      reps: results[:reps],
      sets: results[:series_count],
      duration: duration,
      updated_at: Time.now
    )
  end

  def edit
  end

  def update
    respond_to do |format|
      if @exercise_set.update(exercise_set_params)
        format.html { redirect_to @exercise_set, notice: 'Exercise set was successfully updated.' }
        format.json { render json: { status: "success", weight: @exercise_set.weight } }
      else
        format.html { render :edit }
        format.json { render json: { status: "error", message: @exercise_set.errors.full_messages.to_sentence }, status: :unprocessable_entity }
      end
    end
  end

  def update_weight
    if @exercise_set.update(weight: params[:exercise_set][:weight])
      render json: { status: "success", weight: @exercise_set.weight }
    else
      render json: { status: "error", message: @exercise_set.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
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

  def complete
    @exercise_set.update(completed: true)
    redirect_to user_index_machines_path, notice: 'Exercise set was successfully completed.'
  end

  private

  def set_exercise_set
    @exercise_set = ExerciseSet.find(params[:id])
  end

  def exercise_set_params
    params.require(:exercise_set).permit(:reps, :sets, :weight, :rest_time, :energy_consumed)
  end

  def calculate_duration(data)
    if data.last
      (data.last.recorded_at - data.first.recorded_at).to_i
    else
      0
    end
  end

  def detect_series_and_reps(data)
    series_count = 0
    reps = 0
    in_series = false
    ready_for_new_rep = true
    consecutive_low_values = 0
    current_series_has_reps = false

    data.each_with_index do |value, index|
      log_message = "Value ID #{index + 1}: #{value}"

      # Detect the start of a series
      if !in_series && value > -1400
        in_series = true
        ready_for_new_rep = true
        consecutive_low_values = 0
        current_series_has_reps = false  # Reset for the new series
        log_message += ", Série iniciada"
      end

      # Count repetitions
      if in_series
        if value > -880 && ready_for_new_rep
          reps += 1
          ready_for_new_rep = false  # Block further repetitions until value drops below -1050
          current_series_has_reps = true  # Mark that this series has at least one repetition
          log_message += ", Repetição contada"
        end

        if value < -1050
          ready_for_new_rep = true  # Allow a new repetition to be counted when value rises above -880
        end

        # End of the series when value remains below -1400 for 50 consecutive readings
        if value <= -1400
          consecutive_low_values += 1
          log_message += ", Contador de baixa consecutiva: #{consecutive_low_values}"
        else
          consecutive_low_values = 0
        end

        if consecutive_low_values >= 50
          if current_series_has_reps
            series_count += 1  # Only count the series if it had at least one repetition
            log_message += ", Série finalizada com repetições"
          else
            log_message += ", Série descartada (sem repetições)"
          end
          in_series = false  # End the current series
        end
      end

      # Log each step
      Rails.logger.info(log_message)
    end

    { series_count: series_count, reps: reps }
  end



end
