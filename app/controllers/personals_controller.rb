class PersonalsController < ApplicationController
  before_action :authenticate_personal!
  before_action :set_personal, only: %i[show edit update destroy dashboard users_index]
  before_action :ensure_gym_selected, only: [:users_index]

  def index
    @personals = Personal.all
  end

  def users_index
    @gym = current_personal.gyms.find(session[:current_gym_id])

    # Verifica se há um parâmetro de pesquisa 'query'
    if params[:query].present?
      # Filtra os usuários da academia pelo nome que contenha a query (case insensitive)
      @users = @gym.users.where("name ILIKE ?", "%#{params[:query]}%")
    else
      # Se não houver query, retorna todos os usuários da academia
      @users = @gym.users
    end
  end


  def gyms_index
    @gyms = current_personal.gyms
  end

  def select_gym
    gym_id = params[:gym_id]
    gym = current_personal.gyms.find(gym_id)
    session[:current_gym_id] = gym.id
    redirect_to users_index_personal_path(current_personal), notice: "Academia selecionada: #{gym.name}"
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
  end

  private

  def set_personal
    @personal = Personal.find(params[:id])

    # Verificação adicional
    unless @personal.gyms.present? && session[:current_gym_id]
      redirect_to gyms_index_personal_path(current_personal), alert: 'Por favor, selecione uma academia.'
    end
  end

  def personal_params
    params.require(:personal).permit(:user_id, :specialization, :availability, :bio, :rating, :languages, :emergency_contact, :current_clients, :certifications, :photos, :plans, :achievements)
  end

  def ensure_gym_selected
    unless session[:current_gym_id]
      redirect_to gyms_index_personal_path(current_personal), alert: 'Por favor, selecione uma academia.'
    end
  end

end
