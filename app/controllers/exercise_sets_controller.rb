class ExerciseSetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercise_set, only: [:show, :edit, :update, :destroy, :complete, :update_weight]

  def show
    @arduino_data = @exercise_set.arduino_data.order(:recorded_at)

    # Passando os valores de distância reais para o cálculo de sets e repetições
    sets_and_reps = calculate_sets_and_repetitions(@arduino_data.map(&:value))

    duration = calculate_duration(@arduino_data)
    rest_time = calculate_rest_time(@arduino_data)

    sets = sets_and_reps[:sets]
    total_reps = sets_and_reps[:total_reps]

    # Atualizar os atributos do ExerciseSet
    @exercise_set.update(
      reps: total_reps,
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

  # Método atualizado para calcular sets e repetições com base nas distâncias reais
  def calculate_sets_and_repetitions(data)
    # Definindo os limites para transições
    limite_em_serie = 50
    limite_fora_serie = 150
    limite_concentrico_completo = 300
    limite_excentrico_completo = 300
    tolerancia_ruido = 10  # Pequenas variações serão ignoradas

    # Variáveis de controle
    var_concentrico = 0
    var_excentrico = 0
    em_serie = false
    series = 0
    reps_na_serie_atual = 0
    total_reps = 0
    contador_consecutivo_baixo = 0
    fase_concentrica_completa = false
    fase_excentrica_completa = false
    meia_repeticao = false

    # Iterar sobre os dados
    data.each_cons(2).with_index do |(a, b), index|
      variacao = b - a
      distancia_atual = b
      distancia_anterior = a
      diferenca = (distancia_atual - distancia_anterior).abs

      log_message = "Variação #{index + 1}: Distância atual: #{distancia_atual}, Diferença: #{diferenca} "

      # Ignorar pequenas variações
      next if diferenca < tolerancia_ruido

      if em_serie
        if diferenca > limite_em_serie
          if variacao > 0 # Movimento concêntrico
            var_concentrico += variacao
            log_message += "Início de fase concêntrica"

            if var_concentrico >= limite_concentrico_completo
              fase_concentrica_completa = true
              log_message += " -> Fase concêntrica completa"
            end

          elsif variacao < 0 && fase_concentrica_completa # Movimento excêntrico após concêntrico completo
            var_excentrico += variacao.abs
            log_message += " -> Início de fase excêntrica"

            if var_excentrico >= limite_excentrico_completo
              fase_excentrica_completa = true
              total_reps += 1
              reps_na_serie_atual += 1
              log_message += " -> Repetição #{reps_na_serie_atual} completa -> Fim de fase excêntrica"

              # Reseta variáveis após repetição completa
              var_concentrico = 0
              var_excentrico = 0
              fase_concentrica_completa = false
              fase_excentrica_completa = false
            end
          end

          # Resetar contador de movimento baixo
          contador_consecutivo_baixo = 0
        else
          contador_consecutivo_baixo += 1

          # Condição de fim de série
          if contador_consecutivo_baixo >= 5
            if reps_na_serie_atual > 0
              series += 1
              log_message += " -> Fim de série com #{reps_na_serie_atual} repetições"
            else
              log_message += " -> Fim de série sem repetições"
            end
            em_serie = false
            reps_na_serie_atual = 0
          end
        end
      else
        # Início de uma nova série
        if diferenca > limite_fora_serie
          em_serie = true
          log_message += "Início de série"
        end
      end

      # Adicionar log para análise
      Rails.logger.info log_message.strip
    end

    # Adiciona a última série se ainda estiver aberta
    if em_serie && reps_na_serie_atual > 0
      series += 1
      Rails.logger.info "Fim de série com #{reps_na_serie_atual} repetições"
    end

    # Retorno do resultado
    Rails.logger.info "Total de séries detectadas: #{series}, Total de repetições: #{total_reps}"

    { sets: series, total_reps: total_reps }
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
end
