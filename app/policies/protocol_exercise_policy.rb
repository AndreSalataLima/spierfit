class ProtocolExercisePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.present?

      scope.joins(:workout_protocol).where(
        WorkoutProtocolPolicy::Scope.new(user, WorkoutProtocol).resolve
          .select(:id)
          .then { |q| { workout_protocol_id: q } }
      )
    end
  end

  def index?;    user.present?; end
  def show?;     user.present? && (record.workout_protocol.user_id == user.id || record.workout_protocol.personal_id == user.id); end
  def create?;   show?; end
  def update?;   show?; end
  def destroy?;  show?; end
end
