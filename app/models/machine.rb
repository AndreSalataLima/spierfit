class Machine < ApplicationRecord
  belongs_to :current_user, class_name: 'User', optional: true
  belongs_to :gym
  has_many :exercise_sets
  has_and_belongs_to_many :exercises
  has_many :workouts, through: :exercise_sets


  after_initialize :set_default_status, if: :new_record?

  # validates :mac_address, presence: true, uniqueness: true
  validates :name, presence: true

  private

  def set_default_status
    self.status ||= 'ativo'
  end

end
