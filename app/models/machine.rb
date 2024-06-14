class Machine < ApplicationRecord
  belongs_to :gym, optional: true
  has_many :exercisesets
  has_and_belongs_to_many :exercises

end
