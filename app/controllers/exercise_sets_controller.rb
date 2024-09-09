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
    calculate_force_and_power_from_arduino_data(@arduino_data)
  end

  def edit
    @arduino_data = @exercise_set.arduino_data.order(:recorded_at)
    calculate_force_and_power_from_arduino_data(@arduino_data)

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

  # Função para calcular a força e potência e atualizar os campos no banco de dados
  def calculate_force_and_power_from_arduino_data(arduino_data)
    total_eccentric_time = 0
    total_concentric_time = 0
    total_distance = 0

    # Processar dados do Arduino para calcular tempo excêntrico, concêntrico e distância
    arduino_data.each_cons(2) do |prev, curr|
      # Verificar se ambos os valores estão acima de -1400
      next if prev.value.abs < 1400 || curr.value.abs < 1400

      delta_value = curr.value - prev.value
      total_distance += delta_value.abs # Somar a distância absoluta entre valores consecutivos

      # Calcular o tempo de movimento para cada fase (concêntrica/excêntrica)
      if delta_value > 0
        total_concentric_time += 1 / 5.0 # Concêntrico: peso subindo
      elsif delta_value < 0
        total_eccentric_time += 1 / 5.0 # Excêntrico: peso descendo
      end
    end

    # Converter a distância total de milímetros para metros
    total_distance_in_meters = total_distance / 1000.0

    # Tempo total
    total_time = total_concentric_time + total_eccentric_time

    # Calcular a força com base no peso e no tempo
    time_per_series = calculate_time_proportion_per_series

    total_eccentric_force = 0
    total_concentric_force = 0

    time_per_series.each do |series_number, series_data|
      weight = series_data[:weight].to_f
      proportion_eccentric = series_data[:eccentric_time_proportion].to_f
      proportion_concentric = series_data[:concentric_time_proportion].to_f

      eccentric_force = weight * 9.81 * proportion_eccentric
      total_eccentric_force += eccentric_force

      concentric_force = weight * 9.81 * proportion_concentric
      total_concentric_force += concentric_force
    end

    # Força média total
    total_average_force = (total_eccentric_force + total_concentric_force) / 2.0

    # Calcular a potência em watts e formatar com 1 casa decimal
    power_in_watts = total_time > 0 ? (total_average_force * total_distance_in_meters) / total_time : 0
    power_in_watts = power_in_watts.round(1) # Formatar para 1 casa decimal

    # Atualizar os campos average_force e power_in_watts no banco de dados
    @exercise_set.update(average_force: total_average_force, power_in_watts: power_in_watts)

    # Exibir os valores para conferência
    puts "Total Time: #{total_time}"
    puts "Total Eccentric Time: #{total_eccentric_time}"
    puts "Total Concentric Time: #{total_concentric_time}"
    puts "Total Distance: #{total_distance}"
    puts "Total Distance in Meters: #{total_distance_in_meters}"
    puts "Total Eccentric Force: #{total_eccentric_force}"
    puts "Total Concentric Force: #{total_concentric_force}"
    puts "Total Average Force: #{total_average_force}"
    puts "Power in Watts: #{power_in_watts}" # Exibir formatado
  end



  # Função auxiliar para calcular a proporção de tempo para cada série
  def calculate_time_proportion_per_series
    total_reps = @exercise_set.reps_per_series.values.sum { |data| data["reps"] }
    time_per_series = {}

    @exercise_set.reps_per_series.each do |series_number, series_data|
      reps_in_series = series_data["reps"].to_f
      weight_in_series = series_data["weight"]

      eccentric_time_proportion = reps_in_series / total_reps
      concentric_time_proportion = reps_in_series / total_reps

      time_per_series[series_number] = {
        reps: reps_in_series,
        weight: weight_in_series,
        eccentric_time_proportion: eccentric_time_proportion,
        concentric_time_proportion: concentric_time_proportion
      }
    end

    time_per_series
  end

end
