require 'rails_helper'

RSpec.describe WorkoutProtocol, type: :model do
  describe "Validações" do
    let(:user) { User.create!(name: "João Silva", email: "joao@example.com", password: "password123") }
    let(:gym) { Gym.create!(name: "Academia X", email: "gym@example.com", password: "password123") }

    it "é válido com um nome e uma meta de execução positiva" do
      workout_protocol = WorkoutProtocol.new(name: "Treino A", execution_goal: 10, user: user, gym: gym)
      expect(workout_protocol).to be_valid
    end

    it "é inválido sem um nome" do
      workout_protocol = WorkoutProtocol.new(name: nil, execution_goal: 10, user: user, gym: gym)
      expect(workout_protocol).to_not be_valid
    end

    it "é inválido sem uma meta de execução" do
      workout_protocol = WorkoutProtocol.new(name: "Treino A", execution_goal: nil, user: user, gym: gym)
      expect(workout_protocol).to_not be_valid
    end

    it "é inválido com uma meta de execução negativa" do
      workout_protocol = WorkoutProtocol.new(name: "Treino A", execution_goal: -5, user: user, gym: gym)
      expect(workout_protocol).to_not be_valid
    end
  end

  describe "Associações" do
    it { should belong_to(:user) }
    it { should belong_to(:personal).optional }
    it { should belong_to(:gym) }
    it { should have_many(:protocol_exercises).dependent(:destroy) }
  end

  
end
