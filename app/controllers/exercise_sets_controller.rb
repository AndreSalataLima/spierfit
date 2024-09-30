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
    :reps_and_sets,
    :process_new_data
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
    render json: { reps: last_series_details["reps"], sets: last_series_number, in_series: @exercise_set.in_series }
  end


  # Método para atualizar o conjunto de exercícios
  def update
    if @exercise_set.update(exercise_set_params)
      broadcast_exercise_set_data
      redirect_to edit_exercise_set_path(@exercise_set), notice: 'Exercise set was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_weight
    new_weight = params[:exercise_set][:weight].to_f

    if @exercise_set.update(weight: new_weight)
      # **No need to call recalculate_and_update_exercise_set here**
      # The weight will be captured when the next series starts

      broadcast_exercise_set_data
      render json: { status: "success", weight: @exercise_set.weight }
    else
      render json: { status: "error", message: @exercise_set.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end



  def update_rest_time
    if @exercise_set.update(rest_time: params[:rest_time])
      # No need to call `recalculate_and_update_exercise_set` here
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
      weight: @exercise_set.weight,
      energy_consumed: @exercise_set.energy_consumed
    }

    # Use uma variável de cache para armazenar o último dado transmitido
    @last_broadcasted ||= {}

    # Só transmita se houver alterações
    unless current_broadcast == @last_broadcasted
      ActionCable.server.broadcast(
        "exercise_sets_#{@exercise_set.id}_channel",
        current_broadcast
      )
      @last_broadcasted = current_broadcast
    end
  end


  def process_new_data
    Rails.logger.info "Processing new data for ExerciseSet ID: #{@exercise_set.id}"
    @arduino_data = @exercise_set.arduino_data.order(:recorded_at)
    Rails.logger.info "Arduino data count: #{@arduino_data.count}"
    recalculate_and_update_exercise_set(@arduino_data)
    render json: { status: 'processed' }
  end

  private

  def set_exercise_set
    @exercise_set = ExerciseSet.find(params[:id])
  end

  def exercise_set_params
    params.require(:exercise_set).permit(:reps, :sets, :weight, :rest_time, :energy_consumed, reps_per_series: {})
  end

  def recalculate_and_update_exercise_set(arduino_data)
    Rails.logger.info "Recalculating ExerciseSet ID: #{@exercise_set.id}"

    # Use all data for calculations
    results = detect_series_and_reps(arduino_data)

    new_reps = results[:reps_per_series].values.last&.dig('reps') || 0
    new_sets = results[:series_count]
    in_series = results[:in_series]

    # Update reps_per_series and other attributes as needed
    results[:reps_per_series].each do |series_number, series_data|
      series_data['weight'] ||= @exercise_set.weight
    end

    # Update only if there are changes
    if new_reps != @exercise_set.reps || new_sets != @exercise_set.sets || in_series != @exercise_set.in_series
      @exercise_set.update(
        reps_per_series: results[:reps_per_series],
        sets: new_sets,
        reps: new_reps,
        in_series: in_series,
        updated_at: Time.now
      )
      broadcast_exercise_set_data
    end
  end



  # Método para detectar séries e repetições nos dados do Arduino
  def detect_series_and_reps(arduino_data)
    puts "Raw data: #{arduino_data.map { |d| "#{d.id}: #{d.recorded_at.strftime('%Y-%m-%d %H:%M:%S.%L')} - #{d.value}" }}"

    series_count = 0
    reps_in_current_series = 0
    in_series = false
    ready_for_new_rep = true
    consecutive_low_values = 0
    reps_per_series = @exercise_set.reps_per_series.deep_dup || {}
    previous_series_end_time = nil
    series_start_time = nil

    arduino_data.each_with_index do |data_point, index|
      value = data_point.value
      time = data_point.recorded_at

      if !in_series && value > -1400
        # Start of a new series
        in_series = true
        ready_for_new_rep = true
        consecutive_low_values = 0
        reps_in_current_series = 0
        series_count += 1

        series_start_time = time

        # **Calculate rest time for the previous series**
        if previous_series_end_time
          rest_time = (series_start_time - previous_series_end_time).to_i # in seconds
          rest_time = [rest_time, 0].max # Ensure rest_time is not negative

          # **Update rest time for the previous series**
          reps_per_series[(series_count - 1).to_s]['rest_time'] = rest_time
        end

        # Determine the weight at this time
        current_weight = @exercise_set.weight

        # Initialize series in reps_per_series
        reps_per_series[series_count.to_s] ||= {
          'reps' => 0,
          'weight' => current_weight,
          'rest_time' => 0
        }

        Rails.logger.info "Started series #{series_count} at index #{index}, recorded_at: #{time}"
      elsif in_series
        # Process repetitions (existing logic)
        if value > -880 && ready_for_new_rep
          reps_in_current_series += 1
          ready_for_new_rep = false

          # Update reps in reps_per_series
          reps_per_series[series_count.to_s]['reps'] = reps_in_current_series

          Rails.logger.info "Detected rep #{reps_in_current_series} in series #{series_count} at index #{index}, recorded_at: #{time}"
        end

        if value < -1050
          ready_for_new_rep = true
        end

        if value <= -1400
          consecutive_low_values += 1
        else
          consecutive_low_values = 0
        end

        # End of the series (when we reach 50 consecutive low values)
        if consecutive_low_values >= 50
          in_series = false

          # **Adjust previous_series_end_time to the actual end time of the series**
          previous_series_end_time = time - 5.seconds

          Rails.logger.info "Ended series #{series_count} at index #{index}, recorded_at: #{time}"
        end
      end
    end

    { series_count: series_count, reps_per_series: reps_per_series, in_series: in_series }
  end



  def weight_at_time(time, weight_changes)
    # Default weight
    weight_at_time = @exercise_set.weight

    weight_changes.each do |change|
      change_time = Time.parse(change["changed_at"])
      if change_time <= time
        weight_at_time = change["weight"]
      else
        break
      end
    end

    weight_at_time
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
    total_reps = @exercise_set.reps_per_series.values.sum { |data| data["reps"].to_i }
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
