class UserInfo
  include ActionView::Helpers::AssetTagHelper
  include ERB::Util
  include Rails.application.routes.url_helpers

  @current_user = nil;

  def initialize(user = nil)
    @current_user = user
    @auth_engine = Authorization::Engine.new
  end

  def user_info
    {
      id: @current_user.id,
      name: @current_user.name,
      email: @current_user.email,
      profile_image: @current_user.profile_image,
      role_titles: @current_user.role_symbols,
      is_admin: @current_user.is_admin,
      requires_auth: @current_user.requires_auth,
      authRules: auth_rules
    }
  end

private

  def auth_rules
    privileges = @auth_engine.privileges_reader.privilege_hierarchy.inject({}) do |r, (k,v)|
      r[k] = v.flatten.compact
      r
    end

    all_user_role_symbols = @auth_engine.roles_with_hierarchy_for(@current_user)

    auth_rules = @auth_engine.auth_rules_reader.auth_rules.inject({}) do |rules, rule|
      if (all_user_role_symbols.include? rule.role)
        key = rule.contexts.to_a[0].to_s.camelize(:lower)
        permissions = rule.privileges.map do |el|
          privileges.keys.include?(el) ? privileges[el] : el
        end
        rules[key] ||= []
        (rules[key] += permissions.flatten).uniq!
      end
      rules
    end
    auth_rules
  end
end
