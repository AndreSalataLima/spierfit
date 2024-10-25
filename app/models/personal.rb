class Personal < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  belongs_to :gym
  has_and_belongs_to_many :users
  has_many :workouts
end
