class Gym < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :workouts, dependent: :nullify

  validates :name, presence: true
  validates :photos, presence: true
  validates :capacity, presence: true
end
