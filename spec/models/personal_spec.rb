require 'rails_helper'

RSpec.describe Personal, type: :model do
  describe "Validações" do
    it "é válido com um nome e email" do
      personal = Personal.new(name: "Carlos Silva", email: "personal@example.com", password: "password123")
      expect(personal).to be_valid
    end

    it "é inválido sem um email" do
      personal = Personal.new(name: "Carlos Silva", email: nil, password: "password123")
      expect(personal).to_not be_valid
    end
  end

  describe "Associações" do
    it { should have_and_belong_to_many(:gyms) }
    it { should have_many(:users).through(:gyms) }
    it { should have_many(:workouts) }
    it { should have_many(:workout_protocols) }
  end

  describe "Autenticação Devise" do
    it "permite criar um usuário com senha válida" do
      personal = Personal.create(name: "Carlos Silva", email: "personal@example.com", password: "password123")
      expect(personal.valid_password?("password123")).to be true
    end

    it "não autentica com senha incorreta" do
      personal = Personal.create(name: "Carlos Silva", email: "personal@example.com", password: "password123")
      expect(personal.valid_password?("wrongpassword")).to be false
    end
  end


end
