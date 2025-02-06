require 'rails_helper'

RSpec.describe Machine, type: :model do

  describe "Validações" do
    it "é válido com um nome e um mac_address" do
      gym = Gym.create!(name: "Academia X", email: "gym@example.com", password: "password123")
      machine = Machine.new(name: "Leg Press", gym: gym, mac_address: "00:1A:2B:3C:4D:5E")

      expect(machine).to be_valid
    end

    it "é inválido sem um mac_address" do
      gym = Gym.create!(name: "Academia X", email: "gym@example.com", password: "password123")
      machine = Machine.new(name: "Leg Press", gym: gym, mac_address: nil)

      expect(machine).to_not be_valid
    end

    it "é inválido com um mac_address duplicado" do
      gym = Gym.create!(name: "Academia X", email: "gym@example.com", password: "password123")
      Machine.create!(name: "Leg Press", gym: gym, mac_address: "00:1A:2B:3C:4D:5E")
      duplicate_machine = Machine.new(name: "Hack Squat", gym: gym, mac_address: "00:1A:2B:3C:4D:5E")

      expect(duplicate_machine).to_not be_valid
    end
  end

  describe "Associações" do
    it { should belong_to(:gym) }
    it { should have_many(:exercise_sets) }
    it { should have_many(:workouts).through(:exercise_sets) }
    it { should have_and_belong_to_many(:exercises) }
  end

  describe "Callbacks" do
    it "define o status como 'ativo' se não for especificado" do
      gym = Gym.create!(name: "Academia X", email: "gym@example.com", password: "password123")
      machine = Machine.create!(name: "Leg Press", gym: gym, mac_address: "00:1A:2B:3C:4D:5E")

      expect(machine.status).to eq("ativo")
    end

    it "mantém o status definido pelo usuário" do
      gym = Gym.create!(name: "Academia X", email: "gym@example.com", password: "password123")
      machine = Machine.create!(name: "Leg Press", gym: gym, mac_address: "00:1A:2B:3C:4D:5E", status: "em manutenção")

      expect(machine.status).to eq("em manutenção")
    end
  end

end
