require 'rails_helper'

RSpec.describe Workout, type: :model do
  describe "Associações" do
    it { should belong_to(:user).optional }
    it { should belong_to(:personal).optional }
    it { should belong_to(:gym).optional }
    it { should have_many(:exercise_sets) }
    it { should have_many(:exercises).through(:exercise_sets) }
  end

  describe "Métodos de Instância" do
    let(:user) { User.create!(name: "João Silva", email: "joao@example.com", password: "password123") }
    let(:workout) { Workout.create!(user: user) }
    let(:exercise) { Exercise.create!(name: "Supino") } # Criando um exercício válido
    let(:exercise_set1) { ExerciseSet.create!(workout: workout, exercise: exercise, reps: 10, sets: 3) }
    let(:exercise_set2) { ExerciseSet.create!(workout: workout, exercise: exercise, reps: 12, sets: 4) }

    before do
      # Agora incluindo um mac_address válido
      DataPoint.create!(exercise_set: exercise_set1, value: 15, mac_address: "AA:BB:CC:DD:EE:FF")
      DataPoint.create!(exercise_set: exercise_set2, value: 20, mac_address: "11:22:33:44:55:66")
    end

    it "#total_distance retorna a soma dos valores de data_points" do
      expect(workout.total_distance).to eq(35)
    end

    it "#total_duration retorna a soma das durações dos exercise_sets" do
      exercise_set1.update!(duration: 30)
      exercise_set2.update!(duration: 50)

      expect(workout.total_duration).to eq(80)
    end
  end
end
