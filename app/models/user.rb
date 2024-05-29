class User < ApplicationRecord
  has_secure_password
  belongs_to :gym, optional: true
  belongs_to :personal, optional: true
  has_many :workouts
end
