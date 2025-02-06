require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Validações" do
    it "é válido com um nome e email" do
      user = User.new(name: "João Silva", email: "joao@example.com", password: "password123")
      expect(user).to be_valid
    end

    it "é inválido sem um nome" do
      user = User.new(name: nil, email: "joao@example.com", password: "password123")
      expect(user).to_not be_valid
    end

    it "é inválido sem um email" do
      user = User.new(name: "João Silva", email: nil, password: "password123")
      expect(user).to_not be_valid
    end

    it "é inválido com um email duplicado" do
      User.create!(name: "João Silva", email: "joao@example.com", password: "password123")
      user_duplicado = User.new(name: "Outro Nome", email: "joao@example.com", password: "password123")

      expect(user_duplicado).to_not be_valid
    end
  end

  describe "Associações" do
    it { should have_and_belong_to_many(:gyms) }
    it { should have_many(:personals).through(:gyms) }
    it { should have_many(:workouts) }
    it { should have_many(:exercise_sets).through(:workouts) }
    it { should have_many(:workout_protocols) }
  end

  describe "Autenticação Devise" do
    it "permite criar um usuário com senha válida" do
      user = User.create(name: "João Silva", email: "joao@example.com", password: "password123")
      expect(user.valid_password?("password123")).to be true
    end

    it "não autentica com senha incorreta" do
      user = User.create(name: "João Silva", email: "joao@example.com", password: "password123")
      expect(user.valid_password?("wrongpassword")).to be false
    end
  end

  
end
