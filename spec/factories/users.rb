FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@teste.com" }
    password { '12345678' }
    name { 'Test User' }
    role { :user }

    trait :superadmin do
      role { :superadmin }
    end
  end
end
