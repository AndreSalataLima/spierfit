class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  alias_method :show?,   :index?
  alias_method :create?, :index?
  alias_method :update?, :index?
  alias_method :destroy?,:index?

  def new?
    create?
  end

  def edit?
    update?
  end

  def superadmin?
    user&.superadmin?
  end

  def allow_superadmin
    return true if superadmin?
    yield
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
