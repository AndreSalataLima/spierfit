class MachinesController < ApplicationController
  before_action :authenticate_gym!
  before_action :set_machine, only: [:show, :edit, :update, :destroy]

  def index
    @machines = current_gym.machines
  end

  def show
  end

  def new
    @machine = current_gym.machines.build
  end

  def create
    @machine = current_gym.machines.build(machine_creation_params)
    if @machine.save
      redirect_to @machine, notice: 'Machine was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @machine.update(machine_update_params)
      redirect_to @machine, notice: 'Machine was successfully updated.'
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

  def machine_creation_params
    params.require(:machine).permit(:name, :description, :status).tap do |machine_params|
      machine_params[:compatible_exercises] = params[:machine][:compatible_exercises].split(',').map(&:strip)
    end
  end

  def machine_update_params
    params.require(:machine).permit(:name, :description, :status).tap do |machine_params|
      machine_params[:compatible_exercises] = params[:machine][:compatible_exercises].split(',').map(&:strip)
    end
  end
end
