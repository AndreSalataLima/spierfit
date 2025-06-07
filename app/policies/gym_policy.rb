class GymPolicy < ApplicationPolicy

  def index?
    superadmin_or_gym?
  end

  alias_method :show?, :index?
  alias_method :update?, :index?

  def create?
    user&.superadmin?
  end

  class Scope < Scope
    def resolve
      if user&.superadmin?
        scope.all
      elsif user&.gym?
        scope.all
      else
        scope.none
      end
    end
  end

  private

  def superadmin_or_gym?
    user&.superadmin? || user&.gym?
  end
end
