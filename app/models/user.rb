class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { superadmin: 0, user: 1, gym: 2, personal: 3 }

  include DeviseTokenAuth::Concerns::User

  has_and_belongs_to_many :gyms
  has_many :personals, through: :gyms
  has_many :workouts, dependent: :destroy
  has_many :exercise_sets, through: :workouts
  has_many :workout_protocols, dependent: :destroy
end
