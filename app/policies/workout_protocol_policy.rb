class WorkoutProtocolPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.present?

      if user.personal?
        # personal vê protocolos que ele criou
        scope.where(personal_id: user.id)
      else
        # usuários “user” e “gym” (e superadmin) só veem seus próprios
        scope.where(user_id: user.id)
      end
    end
  end

  def index?;    user.present?; end
  def show?;     user.present? && (record.user_id == user.id || record.personal_id == user.id); end
  def create?;   user.present?; end
  def update?;   show?; end
  def destroy?;  show?; end
end
