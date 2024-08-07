class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :dashboard]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "User created successfully!"
      redirect_to users_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  def dashboard
    @calories_burned_per_day = @user.workouts.group_by_day_of_week(:created_at, format: "%a").sum(:calories_burned)
    today = Date.today
    @user_age = today.year - @user.date_of_birth.year - ((today.month > @user.date_of_birth.month || (today.month == @user.date_of_birth.month && today.day >= @user.date_of_birth.day)) ? 0 : 1)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :phone, :address, :status, :date_of_birth, :height, :weight, gym_ids: [])
  end
end
