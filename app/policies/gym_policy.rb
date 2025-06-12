class GymPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user&.superadmin?
        scope.all
      elsif user&.gym?
        scope.joins(:users).where(users: { id: user.id }).distinct
      else
        scope.none
      end
    end
  end

  def index?
    superadmin_or_gym?
  end

  def show?
    user&.superadmin? || (user&.gym? && user.gyms.include?(record))
  end

  alias_method :update?, :show?

  def create?
    user&.superadmin?
  end

  private

  def superadmin_or_gym?
    user&.superadmin? || user&.gym?
  end
end
