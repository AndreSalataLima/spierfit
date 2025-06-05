class UserPolicy < ApplicationPolicy

  def index?
    allow_superadmin { user.present? }
  end

  def show?
    allow_superadmin { user.present? && user.id == record.id }
  end

  def create?
    true
  end

  class Scope < Scope
    def resolve
      if user&.superadmin?
        scope.all
      else
        scope.all
      end
    end
  end
end
