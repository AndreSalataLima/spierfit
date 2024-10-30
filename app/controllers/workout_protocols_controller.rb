class WorkoutProtocolsController < ApplicationController
  before_action :set_personal_and_user
  before_action :set_muscle_groups, only: [:new, :create, :edit, :update]
  before_action :set_workout_protocol, only: [:show, :edit, :update, :destroy]

  def index
    @workout_protocols = @user.workout_protocols
  end

  def show
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

  def new
    @workout_protocol = WorkoutProtocol.new
    @personal = current_personal
    @user = User.find(params[:user_id])
    @muscle_groups = ["Peitoral", "Dorsais", "Deltóides", "Trapézio", "Tríceps", "Bíceps", "Antebraço", "Coxas", "Glúteos", "Panturrilhas", "Abdômen e lombar"]
    # @workout_protocol.protocol_exercises.build
  end

  def create
    @workout_protocol = @personal.workout_protocols.new(workout_protocol_params)
    @workout_protocol.user = @user

    if @workout_protocol.save
      redirect_to [@personal, @user, @workout_protocol], notice: 'Protocolo criado com sucesso.'
    else
      render :new
    end
  end


  def edit
  end

  def update
    if @workout_protocol.update(workout_protocol_params)
      redirect_to [@user, @workout_protocol], notice: 'Protocolo de treino atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @workout_protocol.destroy
    redirect_to user_workout_protocols_path(@user), notice: 'Protocolo de treino excluído com sucesso.'
  end

  private

  def set_personal_and_user
    @personal = Personal.find(params[:personal_id])
    @user = @personal.users.find(params[:user_id])
  end

  def set_muscle_groups
    @muscle_groups = [
      'Peitoral', 'Dorsais', 'Deltóides', 'Trapézio', 'Tríceps', 'Bíceps',
      'Antebraço', 'Coxas', 'Glúteos', 'Panturrilhas', 'Abdômen e Lombar'
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
      protocol_exercises_attributes: [
        :muscle_group, :exercise_id, :sets, :min_repetitions, :max_repetitions, :day, :observation
      ]
    )
  end


end
