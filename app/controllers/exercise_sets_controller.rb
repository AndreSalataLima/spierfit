class ExerciseSetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercise_set, only: [:show, :edit, :update, :destroy, :complete, :update_weight, :update_rest_time, :reps_and_sets]

  def show
    @arduino_data = @exercise_set.arduino_data.order(:recorded_at)
    results = detect_series_and_reps(@arduino_data.map(&:value))
    duration = calculate_duration(@arduino_data)

    reps_per_series = @exercise_set.reps_per_series || {}

    results[:reps_per_series].each do |series_number, data|
      unless reps_per_series[series_number]
        reps_per_series[series_number] = {
          reps: data[:reps],
          weight: @exercise_set.weight,
          rest_time: calculate_rest_time(@arduino_data, series_number.to_i)
        }
      else
        reps_per_series[series_number][:reps] = data[:reps]
      end
    end

    # Se reps_per_series estiver vazio, definir valores padrão
    if reps_per_series.empty?
      last_series_reps = 0
      series_count = 0
    else
      last_series_reps = reps_per_series.values.last[:reps]
      series_count = results[:series_count]
    end

    @exercise_set.update(
      reps_per_series: reps_per_series,
      sets: series_count,       # Atualiza o número de séries
      reps: last_series_reps,   # Atualiza o número de repetições
      duration: duration,
      updated_at: Time.now
    )
  end

  def reps_and_sets
    last_series_reps = @exercise_set.reps_per_series.values.last[:reps] || 0
    last_series_number = @exercise_set.reps_per_series.keys.map(&:to_i).max || 1
    render json: { reps: last_series_reps, sets: last_series_number }
  end


  def edit
  end

  def update
    if @exercise_set.update(exercise_set_params)
      redirect_to select_equipment_machines_path, notice: 'Exercise set was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_weight
    if @exercise_set.update(weight: params[:exercise_set][:weight])
      render json: { status: "success", weight: @exercise_set.weight }
    else
      render json: { status: "error", message: @exercise_set.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def complete
    @exercise_set.update(completed: true)
    redirect_to user_index_machines_path, notice: 'Exercise set was successfully completed.'
  end

  def update_rest_time
    if @exercise_set.update(rest_time: params[:rest_time])
      render json: { status: "success", rest_time: @exercise_set.rest_time }
    else
      render json: { status: "error", message: @exercise_set.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def set_exercise_set
    @exercise_set = ExerciseSet.find(params[:id])
  end

  def exercise_set_params
    params.require(:exercise_set).permit(:reps, :sets, :weight, :rest_time, :energy_consumed, reps_per_series: {})
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
    reps_in_current_series = 0
    in_series = false
    ready_for_new_rep = true
    consecutive_low_values = 0
    reps_per_series = {}

    data.each_with_index do |value, index|
      if !in_series && value > -1400
        in_series = true
        ready_for_new_rep = true
        consecutive_low_values = 0
        reps_in_current_series = 0 # Resetar o contador de repetições para a nova série
        series_count += 1 # Incrementa a contagem de séries no início da série
      end

      if in_series
        if value > -880 && ready_for_new_rep
          reps_in_current_series += 1
          ready_for_new_rep = false

          # Registra a série assim que a primeira repetição é detectada
          reps_per_series[series_count.to_s] = {
            reps: reps_in_current_series,
            weight: nil, # Peso será registrado no método show
            rest_time: 0 # Rest time será atualizado no final da série
          }
        end

        if value < -1050
          ready_for_new_rep = true
        end

        if value <= -1400
          consecutive_low_values += 1
        else
          consecutive_low_values = 0
        end

        if consecutive_low_values >= 50
          if reps_in_current_series > 0
            reps_per_series[series_count.to_s][:reps] = reps_in_current_series
          else
            # Se não houve repetições, remover a série do hash
            reps_per_series.delete(series_count.to_s)
            series_count -= 1
          end
          in_series = false
        end
      end
    end

    { series_count: series_count, reps_per_series: reps_per_series }
  end


  def calculate_rest_time(arduino_data, current_series)
    return 0 if current_series <= 1

    last_series_end = arduino_data.last.recorded_at
    previous_series_start = arduino_data.reverse.find { |d| d.value > -1400 }.recorded_at

    rest_time = last_series_end - previous_series_start
    rest_time.to_i
  end
end
