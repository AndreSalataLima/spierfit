FactoryBot.define do
  factory :exercise do
    name          { Faker::Lorem.unique.word.capitalize }
    description   { Faker::Lorem.sentence }
    muscle_group  { %w[peito costas pernas braco ombro].sample }
  end
end
