class WorkoutsController < ApplicationController
  before_action :set_workout, only: %i[show edit update destroy complete]
  before_action :set_workout_protocol, only: [:start_from_protocol]

  def index
    params[:period] ||= 'week'

    @workouts = current_user.workouts

    if params[:day].present? && params[:month].present? && params[:year].present?
      date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      @workouts = @workouts.where(created_at: date.beginning_of_day..date.end_of_day)
    elsif params[:month].present? && params[:year].present?
      date = Date.new(params[:year].to_i, params[:month].to_i)
      @workouts = @workouts.where(created_at: date.beginning_of_month..date.end_of_month)
    elsif params[:year].present?
      date = Date.new(params[:year].to_i)
      @workouts = @workouts.where(created_at: date.beginning_of_year..date.end_of_year)
    end

    # Calcula as calorias queimadas por dia da semana
    @calories_burned_per_day = @workouts.group_by { |workout| workout.created_at.strftime('%a') }
                                         .transform_values { |workouts| workouts.sum(&:calories_burned) }
  end

  def show
    @user = @workout.user
    @workout_duration = calculate_workout_duration
    @exercise_sets = @workout.exercise_sets
  end

  def new
    @workout = Workout.new
  end

  def edit
  end

  def create
    @workout = Workout.new(workout_params)

    if @workout.save
      redirect_to @workout, notice: 'Workout was successfully created.'
    else
      render :new
    end
  end

  def update
    if @workout.update(workout_params)
      redirect_to @workout, notice: 'Workout was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @workout.destroy
    respond_to do |format|
      format.html { redirect_to workouts_url, notice: 'Workout was successfully destroyed.' }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@workout) }
    end
  end

  def complete
    @workout.update(completed: true)
    redirect_to user_index_machines_path, notice: 'Workout was successfully completed.'
  end

  def dashboard
    @gym = current_gym
    # Adicione aqui a lógica específica para carregar os dados do dashboard do usuário
  end

  private

  def calculate_workout_duration
    if @workout.exercise_sets.any?
      start_time = @workout.exercise_sets.first.created_at
      end_time = @workout.exercise_sets.last.updated_at
      Time.at(end_time - start_time).utc.strftime("%Hh%M")
    else
      "00:00:00" # Caso não haja exercícios
    end
  end

  def set_workout
    @workout = Workout.find(params[:id])
  end

  def workout_params
    params.require(:workout).permit(:user_id, :personal_id, :gym_id, :workout_type, :goal, :duration, :calories_burned, :intensity, :feedback, :modifications, :intensity_general, :difficulty_perceived, :performance_score, :auto_adjustments)
  end
end
