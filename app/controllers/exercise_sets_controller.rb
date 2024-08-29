class ExerciseSetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercise_set, only: [:show, :edit, :update, :destroy, :complete, :update_weight]

  def show
    @arduino_data = @exercise_set.arduino_data.order(:recorded_at)

    # Detect series (com lógica para iniciar e finalizar a série)
    series_count = detect_series(@arduino_data.map(&:value))

    duration = calculate_duration(@arduino_data)

    # Sobrescrever o número de séries, mesmo que não tenha séries detectadas (zerar se necessário)
    @exercise_set.update(
      reps: 0,  # Temporariamente, sem lógica de repetições
      sets: series_count,
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

# Detectar o início e fim da série, com log para todos os values
def detect_series(data)
  series_count = 0
  in_series = false
  consecutive_low_variations = 0

  data.each_with_index do |value, index|
    next if index < 4  # Pular os primeiros valores porque precisamos de 4 valores para calcular as 3 últimas variações

    # Calcular as três últimas variações
    variation_1 = data[index - 3] - data[index - 4]
    variation_2 = data[index - 2] - data[index - 3]
    variation_3 = data[index - 1] - data[index - 2]

    # Somar as variações (sem valor absoluto)
    sum_of_variations = variation_1 + variation_2 + variation_3

    # Log para todos os valores
    log_message = "Value #{index + 1}: Distance: #{value}"

    # Detectar o início de uma série
    if !in_series && sum_of_variations > 200
      in_series = true
      series_count += 1
      consecutive_low_variations = 0  # Resetar o contador ao iniciar uma nova série
      log_message += ", Início da série"
    end

    # Verificar o fim da série apenas após a série ter iniciado
    if in_series
      if index > 0
        variation = (value - data[index - 1]).abs

        if variation < 60
          consecutive_low_variations += 1
          log_message += ", Variação consecutiva: #{consecutive_low_variations}"
        else
          consecutive_low_variations = 0  # Resetar contador se a variação for maior que 60
        end

        # Se o contador atingir 50, concluir a série
        if consecutive_low_variations >= 50
          in_series = false
          log_message += ", Fim da série"
        end
      end
    end

    # Imprimir log para cada valor
    Rails.logger.info(log_message)
  end

  series_count
end



end
