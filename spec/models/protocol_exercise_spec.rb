require 'rails_helper'

RSpec.describe ProtocolExercise, type: :model do
  describe "Validações" do
    let(:user) { User.create!(name: "João", email: "joao@example.com", password: "password123") }
    let(:gym) { Gym.create!(name: "Academia X", email: "gym@example.com", password: "password123") }
    let(:workout_protocol) { WorkoutProtocol.create!(name: "Treino A", user: user, gym: gym, execution_goal: 10) }
    let(:exercise) { Exercise.create!(name: "Supino") }

    it "é válido com muscle_group, sets, min_repetitions, max_repetitions, day e exercise" do
      protocol_exercise = ProtocolExercise.new(
        workout_protocol: workout_protocol,
        exercise: exercise,
        muscle_group: "Peito",
        sets: 4,
        min_repetitions: 8,
        max_repetitions: 12,
        day: "Segunda"
      )
      expect(protocol_exercise).to be_valid
    end

    it "é inválido sem muscle_group" do
      protocol_exercise = ProtocolExercise.new(
        workout_protocol: workout_protocol,
        exercise: exercise,
        muscle_group: nil,
        sets: 4,
        min_repetitions: 8,
        max_repetitions: 12,
        day: "Segunda"
      )
      expect(protocol_exercise).to_not be_valid
    end

    it "é inválido sem sets" do
      protocol_exercise = ProtocolExercise.new(
        workout_protocol: workout_protocol,
        exercise: exercise,
        muscle_group: "Peito",
        sets: nil,
        min_repetitions: 8,
        max_repetitions: 12,
        day: "Segunda"
      )
      expect(protocol_exercise).to_not be_valid
    end

    it "é inválido com min_repetitions menor que 1" do
      protocol_exercise = ProtocolExercise.new(
        workout_protocol: workout_protocol,
        exercise: exercise,
        muscle_group: "Peito",
        sets: 4,
        min_repetitions: 0,
        max_repetitions: 12,
        day: "Segunda"
      )
      expect(protocol_exercise).to_not be_valid
    end

    it "é inválido sem exercise_id" do
      protocol_exercise = ProtocolExercise.new(
        workout_protocol: workout_protocol,
        exercise: nil,
        muscle_group: "Peito",
        sets: 4,
        min_repetitions: 8,
        max_repetitions: 12,
        day: "Segunda"
      )
      expect(protocol_exercise).to_not be_valid
    end
  end

  describe "Associações" do
    it { should belong_to(:workout_protocol) }
    it { should belong_to(:exercise) }
  end

end
