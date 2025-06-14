class ExerciseSetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.present?
      scope.joins(:workout).where(workouts: { user_id: user.id })
    end
  end

  def show?; user.present?; end
  def create?; user.present?; end
  def update?; user.present?; end
end
