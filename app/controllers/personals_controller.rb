class PersonalsController < ApplicationController
  before_action :set_personal, only: %i[show edit update destroy]
  # skip_before_action :require_no_authentication, only: [:create]

  def index
    @personals = Personal.all
  end

  def show
  end

  def new
    @personal = Personal.new
  end

  def edit
  end

  def create
    @personal = Personal.new(personal_params)

    if @personal.save
      redirect_to @personal, notice: 'Personal was successfully created.'
    else
      render :new
    end
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
    respond_to do |format|
      format.html { redirect_to personals_url, notice: 'Personal was successfully destroyed.' }
      format.turbo_stream
    end
  end

  private

  def set_personal
    @personal = Personal.find(params[:id])
  end

  def personal_params
    params.require(:personal).permit(:name, :email, :password, :specialization, :availability, :bio, :rating, :languages, :emergency_contact, :current_clients, :certifications, :photos, :plans, :achievements, :user_id)
  end
end
