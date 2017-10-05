class UserMailer < ApplicationMailer
  def authorized_email(user)
    @user = user
    mail(to: @user.email, subject: "Huzzah! Your YouTube Tonight account has been approved!")
  end

  def registered_user(user)
    @user = user
    @emails = User.joins(:roles).where(roles: { title: 'admin' }).select(:email).without_system_admin.collect(&:email) rescue nil
    @emails = [User.find(SYSTEM_ADMIN_ID).email] if @emails.blank?

    if @emails.present?
      mail(to: @emails.join(','), subject: "New user registration at YouTube Tonight")
    end
  rescue Exception => e
    NewRelic::Agent.notice_error(e)
  end
end
