class MachinePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.superadmin?
        scope.all
      elsif user.gym?
        scope.where(gym_id: user.gyms.select(:id))
      else
        scope.none
      end
    end
  end

  def index?
    user.superadmin? || user.gym?
  end

  def show?
    user.superadmin? || (user.gym? && user.gyms.exists?(id: record.gym_id))
  end

alias_method :update?, :show?
alias_method :create?, :show?

end
