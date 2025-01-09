class MachinesController < ApplicationController
  # before_action :authenticate_gym!, except: [:exercises, :start_exercise_set, :user_index, :select_equipment]
  before_action :authenticate_user!, only: [:exercises, :start_exercise_set, :user_index]
  before_action :set_machine, only: [:show, :edit, :update, :destroy, :exercises, :start_exercise_set]
  before_action :set_equipment_list, only: [:new, :create, :edit, :update]

  def index
    @machines = current_gym.machines
  end

  def user_index
    if current_user
      @current_workout = current_user.workouts.find_by(completed: false)
      if @current_workout
        @machines = Machine.where(gym_id: @current_workout.gym_id)
      else
        @machines = []
        flash[:alert] = 'No active workout found'
      end
    else
      redirect_to new_user_session_path
    end
  end

  def show
  end

  def new
    @machine = current_gym.machines.build
    @equipment_list = EQUIPMENT_LIST
    @muscle_groups = Exercise.pluck(:muscle_group).uniq
  end

  def create
    @machine = current_gym.machines.build(machine_params)
    if @machine.save
      redirect_to machine_path(@machine), notice: 'Machine was successfully created.'
    else
      @equipment_list = EQUIPMENT_LIST
      render :new
    end
  end

  def update
    if @machine.update(machine_params)
      # Em caso de sucesso, respondemos com Turbo Stream
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash_messages", locals: { notice: "Distâncias salvas com sucesso." })
        end
        format.html { redirect_to exercises_machine_path(@machine), notice: 'Distâncias salvas com sucesso.' }
      end
    else
      # Em caso de erro, também podemos atualizar a área de flash.
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash_messages", locals: { alert: "Erro ao salvar distâncias." })
        end
        format.html { render :exercises, status: :unprocessable_entity }
      end
    end
  end



  def destroy
    @machine.destroy
    redirect_to machines_path, notice: 'Machine was successfully destroyed.'
  end

  def exercises
    if current_user
      current_user.update(gym_id: @machine.gym_id) if @machine.gym_id.present? && current_user.gym_id != @machine.gym_id
      @exercises = @machine.exercises
      render 'machines/exercises/index'
    else
      redirect_to new_user_session_path
    end
  end

  def select_equipment
    # Aqui você pode adicionar qualquer lógica necessária para a view
  end

  def start_exercise_set
    if current_user
      if @machine.current_user_id.present? && @machine.current_user_id != current_user.id
        redirect_to user_index_machines_path, alert: 'Esta máquina está atualmente em uso por outro usuário.'
        return
      end

      # Bloqueia a máquina para o usuário atual
      @machine.update(current_user_id: current_user.id)

      # 1) Verifica se há um workout em aberto
      workout = current_user.workouts.find_by(completed: false)

      if workout
        # 2) Checa o último exercise_set
        last_set = workout.exercise_sets.order(created_at: :desc).first

        if last_set && (Time.current - last_set.created_at) > 120.minutes
          # 3) Se inativo >120min, encerra esse workout
          workout.update!(completed: true)
          workout = nil
        end
      end

      # 4) Se não existe workout em aberto (ou foi encerrado), cria um novo
      unless workout
        workout = current_user.workouts.create!(
          completed: false,
          gym_id: @machine.gym_id,
          workout_type: 'General',
          goal: 'Fitness'
        )
      end

      # 5) Cria o ExerciseSet
      exercise_set = workout.exercise_sets.create!(
        exercise_id: params[:exercise_id],
        machine_id: @machine.id,
        reps: 0,
        sets: 0,
        weight: 0,
        duration: 0,
        rest_time: 0,
        intensity: '',
        feedback: '',
        max_reps: 0,
        average_force: 0,
        effort_level: '',
        energy_consumed: 0,
        power_in_watts: 0
      )

      redirect_to exercise_set_path(exercise_set)
    else
      redirect_to new_user_session_path
    end
  end

  private

  def set_machine
    if current_gym
      @machine = current_gym.machines.find(params[:id])
    else
      @machine = Machine.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Machine not found'
  end

  def machine_params
    params.require(:machine).permit(:name, :description, :status, :mac_address, :min_distance, :max_distance, exercise_ids: [])
  end

  def set_equipment_list
    @equipment_list = EQUIPMENT_LIST
  end
end
