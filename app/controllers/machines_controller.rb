class MachinesController < ApplicationController
  before_action :authenticate_gym!, except: [:exercises]
  before_action :authenticate_user!, only: [:exercises]
  before_action :set_machine, only: [:show, :edit, :update, :destroy, :exercises]
  before_action :set_equipment_list, only: [:new, :create, :edit, :update]

  def index
    @machines = current_gym.machines
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

  def edit
    @equipment_list = EQUIPMENT_LIST
    @muscle_groups = Exercise.pluck(:muscle_group).uniq
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
    params.require(:machine).permit(:name, :description, :status, compatible_exercises: [])
  end

  def set_equipment_list
    @equipment_list = EQUIPMENT_LIST
  end

end
