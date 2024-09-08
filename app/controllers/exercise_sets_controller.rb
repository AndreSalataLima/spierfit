class ExerciseSetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercise_set, only: [
    :show,
    :edit,
    :update,
    :destroy,
    :complete,
    :update_weight,
    :update_rest_time,
    :reps_and_sets
  ]

  # Método responsável por exibir a página de execução
  def show
    @arduino_data = @exercise_set.arduino_data.order(:recorded_at)
    recalculate_and_update_exercise_set(@arduino_data)
    broadcast_exercise_set_data
  end

  def edit
    @arduino_data = @exercise_set.arduino_data.order(:recorded_at)
  end
  # Método para servir dados de repetições e séries via JSON
  def reps_and_sets
    last_series_number = @exercise_set.reps_per_series.keys.map(&:to_i).max || 0
    last_series_details = @exercise_set.reps_per_series[last_series_number.to_s] || { "reps" => 0 }
    render json: { reps: last_series_details["reps"], sets: last_series_number }
  end

  # Método para atualizar o conjunto de exercícios
  def update
    if @exercise_set.update(exercise_set_params)
      recalculate_and_update_exercise_set(@exercise_set.arduino_data.order(:recorded_at))
      broadcast_exercise_set_data
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to select_equipment_machines_path, notice: 'Exercise set was successfully updated.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("exercise_set_form", partial: "exercise_sets/form", locals: { exercise_set: @exercise_set }) }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end


  def update_weight
    if @exercise_set.update(weight: params[:exercise_set][:weight])
      recalculate_and_update_exercise_set(@exercise_set.arduino_data.order(:recorded_at))
      broadcast_exercise_set_data
      render json: { status: "success", weight: @exercise_set.weight }
    else
      render json: { status: "error", message: @exercise_set.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def update_rest_time
    if @exercise_set.update(rest_time: params[:rest_time])
      recalculate_and_update_exercise_set(@exercise_set.arduino_data.order(:recorded_at))
      broadcast_exercise_set_data
      render json: { status: "success", rest_time: @exercise_set.rest_time }
    else
      render json: { status: "error", message: @exercise_set.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def complete
    @exercise_set.update(completed: true)
    broadcast_exercise_set_data
    redirect_to user_index_machines_path, notice: 'Exercise set was successfully completed.'
  end
  def broadcast_exercise_set_data
    current_broadcast = {
      reps: @exercise_set.reps,
      sets: @exercise_set.sets,
      duration: @exercise_set.duration,
      weight: @exercise_set.weight,
      energy_consumed: @exercise_set.energy_consumed
    }

    # Verifica se há mudanças antes de transmitir
    if current_broadcast != @last_broadcasted
      ActionCable.server.broadcast(
        "exercise_sets_#{@exercise_set.id}_channel",
        current_broadcast
      )
      @last_broadcasted = current_broadcast
    end
  end


  private

  def set_exercise_set
    @exercise_set = ExerciseSet.find(params[:id])
  end

  def exercise_set_params
    params.require(:exercise_set).permit(:reps, :sets, :weight, :rest_time, :energy_consumed, reps_per_series: {})
  end

  def recalculate_and_update_exercise_set(arduino_data)
    results = detect_series_and_reps(arduino_data.map(&:value))
    new_reps = results[:reps_per_series].values.last&.dig(:reps) || 0
    new_sets = results[:series_count]


    # Aqui garantimos que o peso seja salvo para cada série
    results[:reps_per_series].each do |series_number, series_data|
      # Se ainda não há um peso salvo para essa série, atribuímos o peso atual
      unless series_data[:weight]
        series_data[:weight] = @exercise_set.weight
      end
    end

    if new_reps != @exercise_set.reps || new_sets != @exercise_set.sets
      @exercise_set.update(
        reps_per_series: results[:reps_per_series],
        sets: new_sets,
        reps: new_reps,
        updated_at: Time.now
      )
      broadcast_exercise_set_data
    end
  end

  # Método para detectar séries e repetições nos dados do Arduino
  def detect_series_and_reps(data)
    series_count = 0
    reps_in_current_series = 0
    in_series = false
    ready_for_new_rep = true
    consecutive_low_values = 0
    reps_per_series = @exercise_set.reps_per_series.deep_dup # Clonar o reps_per_series para não sobrescrever dados antigos
    previous_series_end_time = nil

    data.each_with_index do |value, index|
      if !in_series && value > -1400
        in_series = true
        ready_for_new_rep = true
        consecutive_low_values = 0
        reps_in_current_series = 0 # Resetar o contador de repetições para a nova série
        series_count += 1 # Incrementa a contagem de séries no início da nova série

        # Atualiza o rest_time da série anterior se ele ainda não tiver sido atualizado
        if series_count > 1 && reps_per_series[(series_count - 1).to_s]["rest_time"] == 0
          rest_time = @exercise_set.rest_time # Usa o valor correto de @exercise_set.rest_time
          reps_per_series[(series_count - 1).to_s]["rest_time"] = rest_time

        end

        # Inicializa a nova série no reps_per_series se ainda não existir
        unless reps_per_series[series_count.to_s]
          reps_per_series[series_count.to_s] = {
            reps: 0, # Inicializa com 0 repetições
            weight: @exercise_set.weight, # Mantém o peso da série atual
            rest_time: 0 # O rest_time da série atual será atualizado na próxima série
          }
        end
      end

      if in_series
        if value > -880 && ready_for_new_rep
          reps_in_current_series += 1
          ready_for_new_rep = false

          # Atualiza o número de repetições para a série atual
          reps_per_series[series_count.to_s][:reps] = reps_in_current_series

          # Atualizar o banco de dados e transmitir a atualização imediatamente após cada repetição
          @exercise_set.update(
            reps_per_series: reps_per_series,
            sets: series_count,
            reps: reps_in_current_series,
            updated_at: Time.now
          )
          broadcast_exercise_set_data
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
          previous_series_end_time = Time.now # Armazena o tempo de término da série atual para cálculo de rest_time na próxima série
        end
      end
    end

    { series_count: series_count, reps_per_series: reps_per_series }
  end



  # Método para calcular a duração do exercício
  def calculate_duration(data)
    if data.last
      (data.last.recorded_at - data.first.recorded_at).to_i
    else
      0
    end
  end

end
