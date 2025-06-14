class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.superadmin?
        scope.all
      elsif user.gym?
        scope.joins(:gyms).where(gyms: { id: user.gym_ids }).distinct
      else
        scope.none
      end
    end
  end

  def index?
    superadmin_or_gym?
  end

  def show?
    return true if user.superadmin?
    return true if user.gym? && (user.gym_ids & record.gym_ids).any?
    user == record
  end

  def update?
    return true if user.superadmin?
    return true if user == record
    return true if user.gym? && (user.gym_ids & record.gym_ids).any?
    false
  end

  alias_method :create?, :index?

  private

  def superadmin_or_gym?
    user.present? && (user.superadmin? || user.gym?)
  end
end
