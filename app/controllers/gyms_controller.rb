class GymsController < ApplicationController
  before_action :authenticate_gym!, only: [:show, :edit, :update, :destroy, :dashboard]
  before_action :set_gym, only: [:show, :edit, :update, :destroy, :dashboard]

  def index
    @gyms = Gym.all
  end

  def show
  end

  def new
    @gym = Gym.new
  end

  def create
    @gym = Gym.new(gym_params)
    if @gym.save
      redirect_to @gym, notice: 'Gym was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @gym.update(gym_params)
      redirect_to @gym, notice: 'Gym was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @gym.destroy
    respond_to do |format|
      format.html { redirect_to gyms_url, notice: 'Gym was successfully destroyed.' }
      format.turbo_stream
    end
  end

  def dashboard
    # @gym já está definido pelo before_action :set_gym
    # Adicione aqui a lógica específica para carregar os dados do dashboard da academia
  end

  private

  def set_gym
    @gym = Gym.find(params[:id])
  end

  def gym_params
    params.require(:gym).permit(:name, :location, :contact_info, :hours_of_operation, :equipment_list, :policies, :subscriptions, :photos, :events, :capacity, :safety_protocols, :email, :password)
  end
end
