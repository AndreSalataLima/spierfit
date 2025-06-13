class Api::V1::WorkoutProtocolsController < Api::V1::BaseController
  before_action :authenticate_user!
  after_action  :verify_policy_scoped, only: [:index]
  after_action  :verify_authorized,     only: [:index, :show, :create, :update, :destroy]

  def index
    protocols = policy_scope(WorkoutProtocol)
    authorize WorkoutProtocol
    render json: protocols.as_json(only: [:id, :name, :description, :user_id, :personal_id])
  end

  def show
    protocol = WorkoutProtocol.find(params[:id])
    authorize protocol
    render json: protocol.as_json(only: [:id, :name, :description, :user_id, :personal_id])
  end

  def create
    protocol = WorkoutProtocol.new(workout_protocol_params)
    protocol.user ||= current_user
    protocol.personal = current_user if current_user.personal?

    authorize protocol

    if protocol.save
      render json: protocol.as_json(only: [:id, :name, :description, :user_id, :personal_id]), status: :created
    else
      render json: { errors: protocol.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def update
    protocol = WorkoutProtocol.find(params[:id])
    authorize protocol

    if protocol.update(workout_protocol_params)
      render json: protocol.as_json(only: [:id, :name, :description, :user_id, :personal_id]), status: :ok
    else
      render json: { errors: protocol.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    protocol = WorkoutProtocol.find(params[:id])
    authorize protocol
    protocol.destroy
    head :no_content
  end

  private

  def workout_protocol_params
    attrs = [:name, :description, :execution_goal, :gym_id]
    attrs << :user_id if current_user.personal?
    params.permit(*attrs)
  end
end
