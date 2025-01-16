class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :dashboard, :prescribed_workouts]

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
    if user_params[:password].blank?
      flash[:alert] = "A senha é necessária para confirmar as alterações."
      redirect_to edit_user_path(@user) and return
    end

    if @user.update(user_params)
      bypass_sign_in(@user)
      redirect_to @user, notice: "Perfil atualizado com sucesso."
    else
      flash[:alert] = @user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end



  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  def dashboard
    @calories_burned_per_day = @user.workouts.group_by_day_of_week(:created_at, format: "%a").sum(:calories_burned)

    if @user.date_of_birth.nil?
      @incomplete_profile = true
    else
      today = Date.today
      @user_age = today.year - @user.date_of_birth.year - ((today.month > @user.date_of_birth.month || (today.month == @user.date_of_birth.month && today.day >= @user.date_of_birth.day)) ? 0 : 1)
    end
  end


  def search
    query = params[:query].to_s.downcase
    gym_id = session[:current_gym_id]

    @users = User.joins(:gyms)
                 .where("lower(users.name) LIKE ?", "%#{query}%")
                 .where(gyms: { id: gym_id })
                 .distinct

    render json: @users.select(:id, :name)
  end


  def prescribed_workouts
    @workout_protocols = @user.workout_protocols.order(created_at: :desc)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :phone, :address, :status, :date_of_birth, :height, :weight, gym_ids: [])
  end
end
