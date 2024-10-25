class PersonalsController < ApplicationController
  before_action :authenticate_personal!
  before_action :set_personal, only: %i[show edit update destroy dashboard users_index]

  def index
    @personals = Personal.all
  end

  def users_index
    @users = if params[:query].present?
               @personal.gym.users.where("name ILIKE ?", "%#{params[:query]}%")
             else
               @personal.gym.users
             end
  end

  def show
  end

  def new
    @personal = Personal.new
  end

  def edit
  end

  def create
    @personal = Personal.new(personal_params)

    if @personal.save
      redirect_to @personal, notice: 'Personal was successfully created.'
    else
      render :new
    end
  end

  def update
    if @personal.update(personal_params)
      redirect_to @personal, notice: 'Personal was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @personal.destroy
    respond_to do |format|
      format.html { redirect_to personals_url, notice: 'Personal was successfully destroyed.' }
      format.turbo_stream
    end
  end

  def dashboard
    # @personal já está definido pelo before_action :set_personal
    # Adicione aqui a lógica específica para carregar os dados do dashboard do personal
  end

  private

  def set_personal
    @personal = Personal.find(params[:id])

    # Verificação adicional
    unless @personal.gym.present?
      redirect_to root_path, alert: "Acesso não autorizado"
    end
  end

  def personal_params
    params.require(:personal).permit(:user_id, :specialization, :availability, :bio, :rating, :languages, :emergency_contact, :current_clients, :certifications, :photos, :plans, :achievements)
  end
end
