class WorkoutPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.present?
      scope.where(user_id: user.id)
    end
  end

  def index?; true; end
  def show?; true; end
  def create?; user.present?; end
  def update?; user.present?; end
end
