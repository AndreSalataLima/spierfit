class Api::V1::MachinesController < Api::V1::BaseController
  before_action :authenticate_user!
  after_action  :verify_policy_scoped, only: [:index]
  after_action  :verify_authorized, except: [:index]

  def index
    machines = policy_scope(Machine)
    authorize Machine
    render json: machines.map { |m|
      m.slice(:id, :name, :status, :gym_id, :mac_address)
    }, status: :ok
  end

  def show
    machine = Machine.find(params[:id])
    authorize machine
    render json: machine.slice(
      :id, :name, :description, :status, :gym_id,
      :mac_address, :compatible_exercises
    ), status: :ok
  end

  def create
    machine = Machine.new(machine_params)
    authorize machine

    if machine.save
      render json: machine.slice(
        :id, :name, :status, :gym_id, :mac_address
      ), status: :created
    else
      render json: { errors: machine.errors.full_messages },
            status: :unprocessable_entity
    end
  end

  def update
    machine = Machine.find(params[:id])
    authorize machine

    if machine.update(machine_params)
      render json: machine.slice(
        :id, :name, :status, :gym_id, :mac_address
      ), status: :ok
    else
      render json: { errors: machine.errors.full_messages },
            status: :unprocessable_entity
    end
  end

  private

  def machine_params
    params.permit(
      :name, :description, :status,
      :gym_id, :mac_address,
      compatible_exercises: []
    )
  end
end
