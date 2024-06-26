class ApplicationPolicy
  attr_reader :user, :record

  ANONYMOUS_USER = :anonymous_user

  def initialize(user, record, opts = {})
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user || opts[:user_optional]
    raise Pundit::NotAuthorizedError, 'record does not exist' unless record

    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
