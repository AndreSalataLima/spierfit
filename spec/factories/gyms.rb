FactoryBot.define do
  factory :gym do
    name { Faker::Company.name }
    email { Faker::Internet.unique.email(domain: 'gym.com') }
    password { '12345678' }
    password_confirmation { '12345678' }
  end
end
