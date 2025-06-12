FactoryBot.define do
  factory :machine do
    name          { Faker::Device.model_name }
    description   { Faker::Lorem.sentence }
    status        { 'ativo' }
    gym
    # mac_address   { Faker::Internet.mac_address }
  end
end
