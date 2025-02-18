require 'rails_helper'

RSpec.describe Exercise, type: :model do
  describe "Validações" do
    it "é válido com um nome" do
      exercise = Exercise.new(name: "Supino")
      expect(exercise).to be_valid
    end

    it "é inválido sem um nome" do
      exercise = Exercise.new(name: nil)
      expect(exercise).to_not be_valid
    end
  end

  describe "Associações" do
    it { should have_and_belong_to_many(:machines) }
    it { should have_many(:exercise_sets) }
    it { should have_many(:protocol_exercises) }
  end


end
