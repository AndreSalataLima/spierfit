class ExercisesController < ApplicationController
  before_action :set_exercise, only: [:show, :edit, :update, :destroy]

  def index
    @exercises = Exercise.all
  end

  def show
    @exercise = Exercise.find(params[:id])

    respond_to do |format|
      format.json { render json: @exercise }
    end
  end

  def new
    @exercise = Exercise.new
  end

  def create
    @exercise = Exercise.new(exercise_params)

    if @exercise.save
      redirect_to @exercise, notice: 'Exercise was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @exercise.update(exercise_params)
      redirect_to @exercise, notice: 'Exercise was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @exercise.destroy
    redirect_to exercises_url, notice: 'Exercise was successfully destroyed.'
  end

  private

  def set_exercise
    @exercise = Exercise.find(params[:id])
  end

  def exercise_params
    params.require(:exercise).permit(:name, :description, :muscle_group, :difficulty, :instructions, :variants, :equipment_needed, :contraindications, :benefits, :duration_suggested, :frequency_recommended, :progression_levels)
  end
end
