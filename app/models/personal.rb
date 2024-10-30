class Personal < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_and_belongs_to_many :gyms
  has_many :users, through: :gyms
  has_many :workouts
  has_many :workout_protocols


  def inspect
    "#<#{self.class} id: #{id}, name: #{name}>"
  end

end
