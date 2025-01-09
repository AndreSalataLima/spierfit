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
    @workout_protocol = if @personal.present?
                          @personal.workout_protocols.new(workout_protocol_params)
                        else
                          @user.workout_protocols.new(workout_protocol_params)
                        end
    @workout_protocol.user = @user

    if @workout_protocol.save
      redirect_to [@user, @workout_protocol], notice: 'Protocolo criado com sucesso.'
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

  def show_day
    @day = params[:day]  # "A", "B", etc.
    @workout_protocol = WorkoutProtocol.find(params[:id])

    # Exercícios do dia
    @protocol_exercises_for_day = @workout_protocol.protocol_exercises
                                                   .includes(:exercise)
                                                   .where(day: @day)

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


  private

  def set_personal_and_user
    @personal = params[:personal_id] && Personal.find_by(id: params[:personal_id])
    @user = User.find(params[:user_id])
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
