class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate_user!, except: [:create]
  after_action  :verify_policy_scoped, only: [:index]
  after_action  :verify_authorized, only: [:show, :create, :update]


  def show
    user = User.find(params[:id])
    authorize user
    render json: user.slice(:id, :name, :email)
  end

  def index
    users = policy_scope(User)
    render json: users.map { |u| u.slice(:id, :name, :email) }
  end

  def create
    user = User.new(user_params)
    authorize user
    if user.save
      render json: user.slice(:id, :name, :email), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    user = User.find(params[:id])
    authorize user

    if user.update(user_params)
      render json: user.slice(:id, :name, :email), status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
