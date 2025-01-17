class PersonalsController < ApplicationController
  before_action :authenticate_gym!, only: [:new, :create]

  before_action :set_personal, only: %i[show edit update destroy dashboard users_index wellness_users_index]
  before_action :ensure_gym_selected, only: [:users_index, :wellness_users_index]
  before_action :set_gym, only: [:new, :create]

  def index
    @gym = Gym.find(params[:gym_id])

    @personals = @gym.personals
  end

  def users_index
    @gym = current_personal.gyms.find(session[:current_gym_id])

    if params[:query].present?
      # Filtrar os alunos do personal na academia selecionada e com protocolos na mesma academia
      @users = User.joins(:workout_protocols)
                   .where(workout_protocols: { personal_id: current_personal.id, gym_id: @gym.id })
                   .where("users.name ILIKE ?", "%#{params[:query]}%")
                   .distinct
    else
      # Listar os alunos do personal na academia selecionada e com protocolos na mesma academia
      @users = User.joins(:workout_protocols)
                   .where(workout_protocols: { personal_id: current_personal.id, gym_id: @gym.id })
                   .distinct
    end
  end

  def wellness_users_index
    @gym = current_personal.gyms.find(session[:current_gym_id])

    # Verifica se há um parâmetro de pesquisa 'query'
    if params[:query].present?
      @users = @gym.users.where("name ILIKE ?", "%#{params[:query]}%")
    else
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
    redirect_to dashboard_personal_path(current_personal), notice: "Academia selecionada: #{gym.name}"
  end

  def show
  end

  def new
    @personal = Personal.new
    @gym_id = params[:gym_id] if params[:gym_id].present?
  end

  def edit
  end

  def create
    gym_id = params[:gym_id]
    @gym = Gym.find(gym_id)

    existing_personal = Personal.find_by(email: personal_params[:email])
    if existing_personal
      if existing_personal.gyms.include?(@gym)
        redirect_to gym_personals_path(@gym), notice: "Personal já está vinculado."
      else
        existing_personal.gyms << @gym
        redirect_to gym_personals_path(@gym), notice: "Personal existente vinculado."
      end
    else
      @personal = Personal.new(personal_params)
      if @personal.save
        @personal.gyms << @gym
        redirect_to gym_personals_path(@gym), notice: "Novo personal criado e vinculado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
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
    @gym = current_personal.gyms.find(session[:current_gym_id])
    @users = @gym.users
  end

  def prescribed_workouts
    @gym = current_personal.gyms.find(session[:current_gym_id])

    if params[:query].present?
      query = "%#{params[:query]}%"
      @workout_protocols = WorkoutProtocol
                           .joins(:user)
                           .where(personal_id: current_personal.id, gym_id: @gym.id)
                           .where("users.name ILIKE ? OR workout_protocols.name ILIKE ?", query, query)
                           .distinct
    else
      @workout_protocols = WorkoutProtocol
                           .where(personal_id: current_personal.id, gym_id: @gym.id)
                           .distinct
    end
  end

  def autocomplete_protocols_and_users
    @gym = current_personal.gyms.find(session[:current_gym_id])
    query = params[:query].to_s.downcase

    results = []

    # 1) Protocolos
    protocols = if query.present?
                  WorkoutProtocol
                    .joins(:user)
                    .where(personal_id: current_personal.id, gym_id: @gym.id)
                    .where("lower(workout_protocols.name) LIKE :q OR lower(users.name) LIKE :q", q: "%#{query}%")
                    .distinct
                else
                  WorkoutProtocol.where(personal_id: current_personal.id, gym_id: @gym.id).distinct
                end

    results += protocols.map do |proto|
      {
        type: 'protocol',
        id: proto.id,
        name: proto.name,
        user_name: proto.user&.name,
        user_id: proto.user_id
      }
    end

    # 2) Alunos
    users = if query.present?
              @gym.users.where("lower(name) LIKE ?", "%#{query}%").distinct
            else
              @gym.users.distinct
            end

    results += users.map do |user|
      {
        type: 'user',
        id: user.id,
        name: user.name
      }
    end

    render json: results
  end

  def filter_protocols
    @gym = current_personal.gyms.find(session[:current_gym_id])
    query = params[:query].to_s.downcase

    if query.present?
      @workout_protocols = WorkoutProtocol
        .joins(:user)
        .where(personal_id: current_personal.id, gym_id: @gym.id)
        .where("lower(users.name) LIKE :q OR lower(workout_protocols.name) LIKE :q", q: "%#{query}%")
        .distinct
    else
      @workout_protocols = WorkoutProtocol
        .where(personal_id: current_personal.id, gym_id: @gym.id)
        .distinct
    end

    render partial: 'protocols_list', locals: { workout_protocols: @workout_protocols }
  end


  def autocomplete_users
    @gym = current_personal.gyms.find(session[:current_gym_id])
    query = params[:query].to_s.downcase

    if query.present?
      @users = @gym.users
                   .where("lower(name) LIKE ?", "%#{query}%")
                   .distinct
    else
      @users = @gym.users.distinct
    end

    render json: @users.select(:id, :name)
  end

  def remove_from_gym
    @personal = Personal.find(params[:id])
    @gym = Gym.find(params[:gym_id])

    # Remove apenas o vínculo na tabela de junção
    @personal.gyms.delete(@gym)

    redirect_to gym_personals_path(@gym), notice: "Vínculo removido com sucesso!"
  end

  def search
    query = params[:query]
    @personals = Personal.where("name ILIKE :query OR email ILIKE :query", query: "%#{query}%")
    render json: @personals.select(:id, :name, :email)
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
    params.require(:personal).permit(
      :name, :email, :password,
      :specialization, :availability, :bio, :rating,
      :languages, :emergency_contact, :current_clients,
      :certifications, :photos, :plans, :achievements
    )
  end

  def ensure_gym_selected
    unless session[:current_gym_id]
      redirect_to gyms_index_personal_path(current_personal), alert: 'Por favor, selecione uma academia.'
    end
  end

  def set_gym
    @gym = Gym.find_by(id: params[:gym_id])
    unless @gym
      redirect_to gyms_path, alert: "Academia não encontrada."
    end
  end

end
