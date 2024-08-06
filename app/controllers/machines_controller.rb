class MachinesController < ApplicationController
  before_action :authenticate_gym!, except: [:exercises, :start_exercise_set, :user_index, :select_equipment]
  before_action :authenticate_user!, only: [:exercises, :start_exercise_set, :user_index]
  before_action :set_machine, only: [:show, :edit, :update, :destroy, :exercises, :start_exercise_set]
  before_action :set_equipment_list, only: [:new, :create, :edit, :update]

  def index
    @machines = current_gym.machines
  end

  def user_index
    if current_user
      @current_workout = current_user.workouts.find_by(completed: false)
      if @current_workout
        @machines = Machine.where(gym_id: @current_workout.gym_id)
      else
        @machines = []
        flash[:alert] = 'No active workout found'
      end
    else
      redirect_to new_user_session_path
    end
  end

  def show
  end

  def new
    @machine = current_gym.machines.build
    @equipment_list = EQUIPMENT_LIST
    @muscle_groups = Exercise.pluck(:muscle_group).uniq
  end

  def create
    @machine = current_gym.machines.build(machine_params)
    if @machine.save
      redirect_to machine_path(@machine), notice: 'Machine was successfully created.'
    else
      @equipment_list = EQUIPMENT_LIST
      render :new
    end
  end

  def update
    if @machine.update(machine_params)
      redirect_to machine_path(@machine), notice: 'Machine was successfully updated.'
    else
      @equipment_list = EQUIPMENT_LIST
      render :edit
    end
  end

  def destroy
    @machine.destroy
    redirect_to machines_path, notice: 'Machine was successfully destroyed.'
  end

  def exercises
    if current_user
      current_user.update(gym_id: @machine.gym_id) if @machine.gym_id.present?
      @exercises = @machine.exercises
      Rails.logger.info "Machine ID: #{params[:id]}"
      Rails.logger.info "Exercises loaded: #{@exercises.map(&:name)}"
      render 'machines/exercises/index'
    else
      redirect_to new_user_session_path
    end
  end

  def start_exercise_set
    if current_user
      workout = current_user.workouts.find_or_create_by!(completed: false) do |workout|
        workout.gym_id = @machine.gym_id
        workout.workout_type = 'General'
        workout.goal = 'Fitness'
      end

      exercise_set = workout.exercise_sets.create!(
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

      redirect_to exercise_set_path(exercise_set)
    else
      redirect_to new_user_session_path
    end
  end

  def select_equipment
    # Aqui você pode adicionar qualquer lógica necessária para a view
  end

  private

  def set_machine
    if current_gym
      @machine = current_gym.machines.find(params[:id])
    else
      @machine = Machine.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Machine not found'
  end

  def machine_params
    params.require(:machine).permit(:name, :description, :status, exercise_ids: [])
  end

  def set_equipment_list
    @equipment_list = EQUIPMENT_LIST
  end
end
