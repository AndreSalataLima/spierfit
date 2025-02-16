class WorkoutProtocolsController < ApplicationController
  before_action :set_personal_and_user, only: [:edit_for_user, :update_for_user,
    :edit_for_personal, :update_for_personal, :destroy]
  before_action :set_muscle_groups, only: [:edit_for_user, :update_for_user,
    :edit_for_personal, :update_for_personal, :destroy]
  before_action :set_workout_protocol, only: [:edit_for_user, :update_for_user,
    :edit_for_personal, :update_for_personal, :destroy]

  def index
    @user = User.find(params[:user_id])
    @workout_protocols = @user.workout_protocols
  end

  def show
    @user = User.find(params[:user_id])
    @workout_protocol = WorkoutProtocol.find(params[:id])

    # Agrupa os exercícios por dia e calcula o progresso de cada dia
    progress_data = {}
    days = @workout_protocol.protocol_exercises.pluck(:day).uniq
    days.each do |day|
      total = @workout_protocol.protocol_exercises.where(day: day).sum(:sets)  # soma das séries planejadas para o dia
      progress_data[day] = { completed: 0, total: total } # inicializa completed como 0
    end

    @progress_data = progress_data
  end

  def new_for_personal
    puts ">>> Entrou em NEW_FOR_PERSONAL, params: #{params.inspect}"

    if params[:protocol_id].present?
      existing_protocol = WorkoutProtocol.find(params[:protocol_id])
      @workout_protocol = existing_protocol.dup
      @workout_protocol.name = "#{existing_protocol.name} (Cópia)"

      existing_protocol.protocol_exercises.each do |pe|
        new_pe = pe.dup
        # Exemplo de debug
        puts ">>> Duplicando exercise ID=#{pe.id} muscle=#{pe.muscle_group}"
        @workout_protocol.protocol_exercises << new_pe
        puts ">>> @workout_protocol.protocol_exercises.count = #{@workout_protocol.protocol_exercises.size}"
          @workout_protocol.protocol_exercises.each do |pe|
            puts "   => PE muscle=#{pe.muscle_group} day=#{pe.day}"
          end
      end
    else
      @workout_protocol = WorkoutProtocol.new
    end

    @muscle_groups = [
      'Peitoral', 'Dorsais', 'Deltóides', 'Trapézio',
      'Tríceps', 'Bíceps', 'Antebraço', 'Coxas',
      'Glúteos', 'Panturrilhas', 'Abdômen e Lombar'
    ]

  end



  # POST /workout_protocols/create_for_personal
  def create_for_personal
    Rails.logger.debug ">>> Parâmetros recebidos: #{params.inspect}"

    authenticate_personal!
    @workout_protocol = current_personal.workout_protocols.new(workout_protocol_params)
    @workout_protocol.gym_id = session[:current_gym_id]

    if @workout_protocol.save
      redirect_to prescribed_workouts_personal_path(current_personal), notice: 'Protocolo criado com sucesso (Personal).'
    else
      @muscle_groups = [
        'Peitoral', 'Dorsais', 'Deltóides', 'Trapézio',
        'Tríceps', 'Bíceps', 'Antebraço', 'Coxas',
        'Glúteos', 'Panturrilhas', 'Abdômen e Lombar'
      ]
      render :new_for_personal, status: :unprocessable_entity
    end
  end

  def new_for_user
    authenticate_user!
    @workout_protocol = WorkoutProtocol.new

    @muscle_groups = [
      'Peitoral', 'Dorsais', 'Deltóides', 'Trapézio',
      'Tríceps', 'Bíceps', 'Antebraço', 'Coxas',
      'Glúteos', 'Panturrilhas', 'Abdômen e Lombar'
    ]

  end

  # POST /workout_protocols/create_for_user
  def create_for_user
    @workout_protocol = current_user.workout_protocols.new(workout_protocol_params)
    @workout_protocol.gym_id = session[:current_gym_id] if session[:current_gym_id].present?

    if @workout_protocol.save
      redirect_to user_workout_protocol_path(current_user, @workout_protocol),
                  notice: 'Protocolo criado com sucesso (Aluno).'
    else
      @muscle_groups = [
        'Peitoral', 'Dorsais', 'Deltóides', 'Trapézio',
        'Tríceps', 'Bíceps', 'Antebraço', 'Coxas',
        'Glúteos', 'Panturrilhas', 'Abdômen e Lombar'
      ]
      render :new_for_user, status: :unprocessable_entity
    end
  end


  def edit_for_user
    @muscle_groups ||= [
      'Peitoral', 'Dorsais', 'Deltóides', 'Trapézio',
      'Tríceps', 'Bíceps', 'Antebraço', 'Coxas',
      'Glúteos', 'Panturrilhas', 'Abdômen e Lombar'
    ]
  end


  def update_for_user
    if @workout_protocol.update(workout_protocol_params)
      redirect_to show_for_user_user_workout_protocol_path(@user, @workout_protocol)
    else
      render :edit_for_user, status: :unprocessable_entity
    end
  end

  def edit_for_personal
    @personal = Personal.find(params[:personal_id])
    @user = User.find(params[:user_id])
    @workout_protocol = WorkoutProtocol.find(params[:id])

    # Certifique-se de que os protocol_exercises estão sendo carregados corretamente
    @workout_protocol = @user.workout_protocols
    .includes(:protocol_exercises)  # se quiser eager load
    .find(params[:id])

    @muscle_groups ||= [
      'Peitoral', 'Dorsais', 'Deltóides', 'Trapézio',
      'Tríceps', 'Bíceps', 'Antebraço', 'Coxas',
      'Glúteos', 'Panturrilhas', 'Abdômen e Lombar'
    ]
  end

  def update_for_personal
    # localiza @workout_protocol
    if @workout_protocol.update(workout_protocol_params)
      redirect_to show_for_personal_personal_user_workout_protocol_path(@personal, @user, @workout_protocol)
    else
      render :edit_for_personal
    end
  end

  def destroy
    @workout_protocol.destroy
    redirect_to user_workout_protocols_path(@user), notice: 'Protocolo de treino excluído com sucesso.'
  end

  def show_day
    @day = params[:day]
    @workout_protocol = WorkoutProtocol.find(params[:id])

    @protocol_exercises_for_day = @workout_protocol.protocol_exercises
                                                   .includes(:exercise)
                                                   .where(day: @day)

    # Pegamos a gym associada a este protocolo (ou user) para puxar as máquinas
    gym_id = @workout_protocol.gym_id || @workout_protocol.user.gym_id  # ou algo assim
    @machines_for_gym = Gym.find(gym_id).machines.includes(:exercises) if gym_id

    # 1. Verificar se há QUALQUER workout aberto para esse user
    other_workout = current_user.workouts.find_by(completed: false)
    if other_workout
      same_protocol = (other_workout.workout_protocol_id == @workout_protocol.id)
      same_day = (other_workout.protocol_day == @day)

      # 2. Se não for o mesmo protocolo e dia...
      unless (same_protocol && same_day)
        if other_workout.workout_protocol_id.nil?
          # Caso 1: O outro workout é LIVRE, então “convertê-lo” em Treino A/B/C
          other_workout.update!(
            workout_protocol_id: @workout_protocol.id,
            protocol_day: @day
          )
          # Ao fazer isso, “other_workout” agora é o que precisamos
        else
          # Caso 2: O outro workout tem OUTRO protocolo => fecha
          other_workout.update!(completed: true)
          other_workout = nil
        end
      end
    end

    # 3. Se não existe outro_workout aberto OU o fechamos
    workout = other_workout
    if workout
      # Verificar inatividade
      last_set = workout.exercise_sets.order(created_at: :desc).first
      if last_set && (Time.current - last_set.created_at) > 120.minutes
        workout.update!(completed: true)
        workout = nil
      end
    end

    # 4. Se, após tudo, não temos workout algum, criamos um
    unless workout
      workout = current_user.workouts.create!(
        workout_protocol_id: @workout_protocol.id,
        protocol_day: @day,
        completed: false
      )
    end

    @workout = workout

    render :show_day
  end

  def assign_to_user
    @workout_protocol = WorkoutProtocol.find(params[:id])
    @user = User.find(params[:user_id])

    # Duplica o protocolo e atribui ao novo aluno
    new_protocol = @workout_protocol.dup
    new_protocol.user = @user
    new_protocol.personal = current_personal
    if new_protocol.save
      redirect_to prescribed_workouts_personal_path(current_personal), notice: 'Protocolo prescrito com sucesso.'
    else
      redirect_to prescribed_workouts_personal_path(current_personal), alert: 'Erro ao prescrever o protocolo.'
    end
  end



  def show_for_user
    # Carrega o user e o protocolo
    @user = User.find(params[:user_id])
    @workout_protocol = @user.workout_protocols.find(params[:id])

    # Lógica de progresso (seja qual for)
    progress_data = {}
    days = @workout_protocol.protocol_exercises.pluck(:day).uniq
    days.each do |day|
      total_sets = @workout_protocol.protocol_exercises.where(day: day).sum(:sets)
      progress_data[day] = { completed: 0, total: total_sets }
    end
    @progress_data = progress_data

    render :show_for_user
  end

  def show_for_personal
    # Carrega personal, user e o protocolo
    @personal = Personal.find(params[:personal_id])
    @user = User.find(params[:user_id])
    @workout_protocol = @user.workout_protocols.find(params[:id])

    # Mesmo cálculo de progresso
    progress_data = {}
    days = @workout_protocol.protocol_exercises.pluck(:day).uniq
    days.each do |day|
      total_sets = @workout_protocol.protocol_exercises.where(day: day).sum(:sets)
      progress_data[day] = { completed: 0, total: total_sets }
    end
    @progress_data = progress_data

    render :show_for_personal
  end



  def copy_protocol
    original_protocol = WorkoutProtocol.find(params[:protocol_id])
    user = User.find(params[:user_id])

    # Cria uma cópia do protocolo
    new_protocol = original_protocol.dup
    new_protocol.user_id = user.id
    new_protocol.personal_id = current_personal.id
    new_protocol.name = "#{original_protocol.name} (Cópia)"

    if new_protocol.save
      # Cria cópias dos protocol_exercises
      original_protocol.protocol_exercises.each do |pe|
        new_pe = pe.dup
        new_pe.workout_protocol_id = new_protocol.id
        new_pe.save
      end

      render json: { success: true, new_protocol_id: new_protocol.id }
    else
      render json: { success: false, errors: new_protocol.errors.full_messages }
    end
  end

  private

  def set_personal_and_user
    # Ex.: se a rota for /personals/:personal_id/users/:user_id/workout_protocols
    if params[:personal_id].present?
      @personal = Personal.find(params[:personal_id])
    end

    # Se a rota for /users/:user_id/workout_protocols
    if params[:user_id].present?
      @user = User.find(params[:user_id])
    end
  end


  def set_muscle_groups
    @muscle_groups = [
      'Peitoral', 'Dorsais', 'Deltóides', 'Trapézio',
      'Tríceps', 'Bíceps', 'Antebraço', 'Coxas',
      'Glúteos', 'Panturrilhas', 'Abdômen e Lombar'
    ]
  end

  def set_workout_protocol
    @workout_protocol = @user.workout_protocols.find(params[:id])
  end

  def workout_protocol_params
    params.require(:workout_protocol).permit(
      :name,
      :description,
      :execution_goal,
      :user_id,
      protocol_exercises_attributes: [
        :id,
        :exercise_id,
        :muscle_group,
        :sets,
        :min_repetitions,
        :max_repetitions,
        :observation,
        :day,
        :_destroy
      ]
    )
  end


end
