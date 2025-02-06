class Gym < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :users
  has_and_belongs_to_many :personals
  has_many :machines
  has_many :workouts, through: :machines

  validates :name, presence: true

end
