class UserPolicy < ApplicationPolicy

  def index?
    user.present?
  end

  def show?
    user.present? && user.id == record.id
  end

  def create?
    true
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
