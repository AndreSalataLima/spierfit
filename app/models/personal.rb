class Personal < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :gyms
  has_and_belongs_to_many :users
  has_many :workouts
end
