# app/controllers/machines_controller.rb
class MachinesController < ApplicationController
  before_action :authenticate_gym!
  before_action :set_gym
  before_action :set_machine, only: [:show, :edit, :update, :destroy]

  def index
    @machines = @gym.machines
  end

  def show
  end

  def new
    @machine = @gym.machines.build
  end

  def edit
  end

  def create
    @machine = @gym.machines.build(machine_params)
    if @machine.save
      redirect_to [@gym, @machine], notice: 'Machine was successfully created.'
    else
      render :new
    end
  end

  def update
    if @machine.update(machine_params)
      redirect_to [@gym, @machine], notice: 'Machine was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @machine.destroy
    redirect_to gym_machines_path(@gym), notice: 'Machine was successfully destroyed.'
  end

  private

  def authenticate_gym!
    redirect_to new_gym_session_path unless gym_signed_in?
  end

  def set_gym
    @gym = current_gym
  end

  def set_machine
    @machine = @gym.machines.find(params[:id])
  end

  def machine_params
    params.require(:machine).permit(:name, :description, :compatible_exercises, :status)
  end
end
