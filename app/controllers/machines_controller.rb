class MachinesController < ApplicationController
  before_action :authenticate_gym!
  before_action :set_machine, only: [:show, :edit, :update, :destroy]
  before_action :set_equipment_list, only: [:new, :create, :edit, :update]

  def index
    @machines = current_gym.machines
  end

  def show
  end

  def new
    @machine = current_gym.machines.build
    @muscle_groups = Exercise.pluck(:muscle_group).uniq
  end

  def create
    @machine = current_gym.machines.build(machine_params)
    if @machine.save
      redirect_to machine_path(@machine), notice: 'Machine was successfully created.'
    else
      render :new
    end
  end

  def edit
    @muscle_groups = Exercise.pluck(:muscle_group).uniq
  end

  def update
    if @machine.update(machine_params)
      redirect_to machine_path(@machine), notice: 'Machine was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @machine.destroy
    redirect_to machines_path, notice: 'Machine was successfully destroyed.'
  end

  private

  def set_machine
    @machine = current_gym.machines.find(params[:id])
  end

  def machine_params
    params.require(:machine).permit(:name, :description, :status, compatible_exercises: [])
  end

  def set_equipment_list
    @equipment_list = EQUIPMENT_LIST
  end
end
