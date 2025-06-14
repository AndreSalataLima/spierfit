class ExercisePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all if user.present?
    end
  end

  def index?
    true
  end

  alias_method :show?, :index?

  def create?
    user&.superadmin?
  end

  alias_method :update?, :create?
end
