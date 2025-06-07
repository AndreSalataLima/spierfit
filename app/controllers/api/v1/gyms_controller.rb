class Api::V1::GymsController < Api::V1::BaseController
  before_action :authenticate_user!
  after_action  :verify_policy_scoped, only: [:index]
  after_action  :verify_authorized, only: [:index, :show, :create, :update]

  def index
    gyms = policy_scope(Gym)
    authorize Gym
    render json: gyms.map { |gym| gym.slice(:id, :name, :email) }
  end

  def show
    gym = Gym.find(params[:id])
    authorize gym
    render json: gym.slice(:id, :name, :email)
  end

  def create
    gym = Gym.new(gym_params)
    authorize gym

    if gym.save
      render json: gym.slice(:id, :name, :email), status: :created
    else
      render json: { errors: gym.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    gym = Gym.find(params[:id])
    authorize gym

    if gym.update(gym_params)
      render json: gym.slice(:id, :name, :email), status: :ok
    else
      render json: { errors: gym.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def gym_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
