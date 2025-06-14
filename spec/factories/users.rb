FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| Faker::Internet.unique.email(name: "user#{n}") }
    password { '12345678' }
    password_confirmation { '12345678' }
    role { :user }

    trait :personal do
      role { :personal }
    end
    
    trait :superadmin do
      role { :superadmin }
    end
  end
end
