class ExerciseSetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercise_set, only: [:show, :edit, :update, :destroy, :complete, :update_weight]

  def show
    @arduino_data = @exercise_set.arduino_data.order(:recorded_at)
    @distance_variation = calculate_distance_variation(@arduino_data)
    @repetitions = calculate_repetitions(@distance_variation)

    duration = calculate_duration(@arduino_data)
    rest_time = calculate_rest_time(@arduino_data)
    sets = calculate_sets(@arduino_data)

    # Atualizar os atributos do ExerciseSet
    @exercise_set.update(
      reps: @repetitions,
      duration: duration,
      rest_time: rest_time,
      sets: sets,
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
    params.require(:exercise_set).permit(:reps, :sets, :weight, :rest_time, :energy_consumed)
  end

  def calculate_distance_variation(data)
    variations = data.each_cons(2).map { |a, b| b.value - a.value }
    variations.each_with_index do |variation, index|
      Rails.logger.info "Variação #{index + 1}: #{variation}"
    end
    variations
  end

  def calculate_repetitions(data)
    limite_em_serie = 50
    limite_fora_serie = 150
    concentric = false
    em_serie = false
    reps = 0

    data.each_cons(2) do |a, b|
      variacao = b - a
      variacao_abs = variacao.abs

      if em_serie
        # Se estiver em série, consideramos variações acima de 50
        if variacao_abs > limite_em_serie
          if variacao > 0
            concentric = true
          elsif variacao < 0 && concentric
            reps += 1
            concentric = false
          end
        else
          em_serie = false # Se a variação for menor que o limite, sai da série
          Rails.logger.info "Fim de série detectado no tempo #{b}. Total de repetições: #{reps}"
        end
      else
        # Se não estiver em série, consideramos variações acima de 150
        if variacao_abs > limite_fora_serie
          em_serie = true
          Rails.logger.info "Início de uma nova série detectado com variação #{variacao_abs}."
          if variacao > 0
            concentric = true
          elsif variacao < 0 && concentric
            reps += 1
            concentric = false
          end
        end
      end
    end

    Rails.logger.info "Total de repetições detectadas: #{reps}"
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
    limite_inicio_serie = 150
    limite_manutencao_serie = 50
    series = 0
    em_serie = false
    contador_consecutivo_baixo = 0
    distancia_inicial = nil

    data.each_cons(2).with_index do |(a, b), i|
      variacao = b.value - a.value

      Rails.logger.info "Variação #{i + 1}: #{variacao}"

      if em_serie
        # Manutenção da série
        if variacao.abs > limite_manutencao_serie
          contador_consecutivo_baixo = 0
        else
          contador_consecutivo_baixo += 1
          # Verifica se a série deve ser finalizada
          if contador_consecutivo_baixo >= 5
            em_serie = false
            Rails.logger.info "Fim de série detectado no tempo #{b.recorded_at}. Total de séries: #{series}"
          end
        end
      else
        # Início de uma nova série
        if variacao > limite_inicio_serie
          series += 1
          em_serie = true
          contador_consecutivo_baixo = 0
          distancia_inicial = a.value
          Rails.logger.info "Início de uma nova série detectado no tempo #{b.recorded_at} com variação #{variacao}. Total de séries: #{series}"
        end
      end
    end

    Rails.logger.info "Total de séries detectadas: #{series}"
    series
  end
end
