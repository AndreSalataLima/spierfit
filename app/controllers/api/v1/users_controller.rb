class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate_user!, except: [:create]
  after_action  :verify_policy_scoped, only: [:index]
  after_action  :verify_authorized, only: [:show, :create]


  def show
    user = User.find(params[:id])
    authorize user
    render json: user.as_json(only: [:id, :name, :email])
  end

  def index
    users = policy_scope(User)
    render json: users.as_json(only: [:id, :name, :email])
  end

  def create
    user = User.new(user_params)
    authorize user
    if user.save
      render json: user.as_json(only: [:id, :name, :email]), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation)
  end

end
