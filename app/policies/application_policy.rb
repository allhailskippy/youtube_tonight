class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    read?
  end

  def show?
    read?
    #scope.where(id: record.id).exists?
  end

  def create?
    manage?
  end

  def new?
    create?
  end

  def update?
    manage?
  end

  def edit?
    update?
  end

  def destroy?
    manage?
  end

  def read?
    manage?
  end

  def manage?
    false
  end

  def has_role?(role)
    user.try(:has_role, role)
  end
  alias_method :has_roles?, :has_role?

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def has_role?(role)
      user.try(:has_role, role)
    end
    alias_method :has_roles?, :has_role?

    def resolve
      scope
    end
  end
end
