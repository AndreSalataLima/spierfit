class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:create]

  def show
    user = User.find(params[:id])
    render json: user.as_json(only: [:id, :name, :email])
  end

  def index
    users = User.all
    render json: users.as_json(only: [:id, :name, :email])
  end

  def create
    user = User.new(user_params)
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
