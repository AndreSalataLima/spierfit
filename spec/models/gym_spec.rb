require 'rails_helper'

RSpec.describe Gym, type: :model do
  describe "Validações" do
    it "é válido com um nome e email" do
      gym = Gym.new(name: "Academia X", email: "gym@example.com", password: "password123")
      expect(gym).to be_valid
    end

    it "é inválido sem um nome" do
      gym = Gym.new(name: nil, email: "gym@example.com", password: "password123")
      expect(gym).to_not be_valid
    end

    it "é inválido sem um email" do
      gym = Gym.new(name: "Academia X", email: nil, password: "password123")
      expect(gym).to_not be_valid
    end
  end

  describe "Associações" do
    it { should have_and_belong_to_many(:users) }
    it { should have_and_belong_to_many(:personals) }
    it { should have_many(:machines) }
    it { should have_many(:workouts).through(:machines) }
  end

  describe "Autenticação Devise" do
    it "permite criar um usuário com senha válida" do
      gym = Gym.create(name: "Academia X", email: "gym@example.com", password: "password123")
      expect(gym.valid_password?("password123")).to be true
    end

    it "não autentica com senha incorreta" do
      gym = Gym.create(name: "Academia X", email: "gym@example.com", password: "password123")
      expect(gym.valid_password?("wrongpassword")).to be false
    end
  end
  
end
