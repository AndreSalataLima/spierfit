class Personal < ApplicationRecord
  belongs_to :user
  has_many :workouts
  has_many :clients, through: :workouts, source: :user
end
