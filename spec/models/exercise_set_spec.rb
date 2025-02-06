require 'rails_helper'

RSpec.describe ExerciseSet, type: :model do

  describe "Validações" do
    it "é válido com workout, exercise e pelo menos 1 repetição" do
      workout = Workout.create!
      exercise = Exercise.create!(name: "Supino")
      exercise_set = ExerciseSet.new(workout: workout, exercise: exercise, reps: 10, sets: 3, weight: 20)

      expect(exercise_set).to be_valid
    end

    it "é inválido sem um workout" do
      exercise = Exercise.create!(name: "Supino")
      exercise_set = ExerciseSet.new(exercise: exercise, reps: 10, sets: 3)

      expect(exercise_set).to_not be_valid
    end

    it "é inválido sem um exercise" do
      workout = Workout.create!
      exercise_set = ExerciseSet.new(workout: workout, reps: 10, sets: 3)

      expect(exercise_set).to_not be_valid
    end

    it "é inválido com repetições negativas" do
      workout = Workout.create!
      exercise = Exercise.create!(name: "Supino")
      exercise_set = ExerciseSet.new(workout: workout, exercise: exercise, reps: -1, sets: 3)

      expect(exercise_set).to_not be_valid
    end

    it "é inválido com sets negativos" do
      workout = Workout.create!
      exercise = Exercise.create!(name: "Supino")
      exercise_set = ExerciseSet.new(workout: workout, exercise: exercise, reps: 10, sets: -3)

      expect(exercise_set).to_not be_valid
    end


  end

  describe "Associações" do
    it { should belong_to(:workout) }
    it { should belong_to(:exercise) }
    it { should belong_to(:machine).optional }
    it { should have_many(:data_points) }
  end


  describe "Callbacks" do
    it "inicializa reps_per_series como um hash vazio se não estiver definido" do
      workout = Workout.create!
      exercise = Exercise.create!(name: "Supino")
      exercise_set = ExerciseSet.create!(workout: workout, exercise: exercise, reps: 10, sets: 3)

      expect(exercise_set.reps_per_series).to eq({})
    end
  end



end
