class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :gyms
  has_and_belongs_to_many :personals
  has_many :workouts
  has_many :exercise_sets, through: :workouts

end
