class PersonalsController < ApplicationController
  before_action :set_personal, only: [:show, :edit, :update, :destroy]

  def index
    @personals = Personal.all
  end

  def show
  end

  def new
    @personal = Personal.new
  end

  def create
    @personal = Personal.new(personal_params)
    if @personal.save
      redirect_to @personal, notice: 'Personal was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @personal.update(personal_params)
      redirect_to @personal, notice: 'Personal was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @personal.destroy
    redirect_to personals_url, notice: 'Personal was successfully destroyed.'
  end

  private

  def set_personal
    @personal = Personal.find(params[:id])
  end

  def personal_params
    params.require(:personal).permit(:user_id, :specialization, :availability, :bio, :rating, :languages, :emergency_contact, :current_clients, :certifications, :photos, :plans, :achievements)
  end
end
