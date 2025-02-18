require 'rails_helper'

RSpec.describe DataPoint, type: :model do
  describe "Validações" do
    it "é válido com um valor e um MAC address" do
      data_point = DataPoint.new(value: 10, mac_address: "AA:BB:CC:DD:EE:FF")
      expect(data_point).to be_valid
    end

    it "é inválido sem um valor" do
      data_point = DataPoint.new(mac_address: "AA:BB:CC:DD:EE:FF")
      expect(data_point).to_not be_valid
    end

    it "é inválido sem um MAC address" do
      data_point = DataPoint.new(value: 10)
      expect(data_point).to_not be_valid
    end
  end

  describe "Associações" do
    it { should belong_to(:exercise_set).optional }
  end

  describe "Callbacks" do
    it "dispara broadcast_data_point após a criação" do
      data_point = DataPoint.new(value: 10, mac_address: "AA:BB:CC:DD:EE:FF")

      expect(data_point).to receive(:broadcast_data_point)
      data_point.save!
    end
  end
end
