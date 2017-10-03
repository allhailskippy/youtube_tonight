class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # Default hierarchy
  def index?; read?; end
  def show?; read?; end
  def create?; manage?; end
  def new?; create?; end
  def update?; manage?; end
  def edit?; update?; end
  def destroy?; manage?; end
  def read?; manage?; end
  def manage?; false; end

  ##
  # Methods for managing what attrs are applied to each policy
  #
  # This will replace all the defaults
  # class NewPolicy < ApplicationPolicy
  #   only_attributes :index?, :custom?
  # end
  #
  # This will add some custom methods to the list of defaults
  # class NewPolicy < ApplicationPolicy
  #   add_attributes :custom?, :custom2?
  # end
  #
  # This will exclude one or more attrs from the defaults
  # class NewPolicy < ApplicationPolicy
  #   exclude_attribute :index?
  # end
  #
  # All of these methods are available singular or plural
  # although each takes the same format for params, so you can send
  # multiple values to a singular method
  DEFAULT_ATTRIBUTES = [
    :index?, :show?, :create?, :new?, :update?,
    :edit?, :destroy?, :read?, :manage?
  ].freeze
  class << self
    # Reads the attrs minus any exclusions
    def attrs
      @attrs ||= DEFAULT_ATTRIBUTES.dup
      @attrs - (@exclude_attributes || [])
    end

    # Use this when you want to fully replace the defaults
    def only_attributes(*t)
      @attrs = t
    end
    alias_method :only_attribute, :only_attributes

    # Will append multiple attrs
    def add_attributes(*t)
      @attrs ||= DEFAULT_ATTRIBUTES.dup
      @attrs += t
    end
    alias_method :add_attribute, :add_attributes

    # Used to exclude attrs from default
    def exclude_attributes(*t)
      @exclude_attributes = *t
    end
    alias_method :exclude_attribute, :exclude_attributes
  end
  def attrs
    self.class.attrs
  end

  # Helper methods
  def has_role?(*role)
    user.try(:has_role, *role)
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

    def has_role?(*role)
      user.try(:has_role, *role)
    end
    alias_method :has_roles?, :has_role?

    def resolve
      scope
    end
  end
end
