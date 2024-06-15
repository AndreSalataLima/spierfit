class Machine < ApplicationRecord
  belongs_to :gym
  has_many :exercise_sets
  has_and_belongs_to_many :exercises

  after_initialize :set_default_status, if: :new_record?

  private

  def set_default_status
    self.status ||= 'ativo'
  end

end
