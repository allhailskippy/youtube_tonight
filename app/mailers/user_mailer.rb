class UserMailer < ActionMailer::Base
  default from: "YouTube Tonight <yttonight@gmail.com>"

  def authorized_email(user)
    @user = user
    mail(to: @user.email, subject: "Huzzah! Your YouTube Tonight account has been approved!")
  end

  def registered_user(user)
    @user = user
    @emails = User.joins(:roles).where(roles: { title: 'admin' }).select(:email).without_system_admin.collect(&:email)
    @emails = [User.find(SYSTEM_ADMIN_ID)] if @emails.blank?
    mail(to: @emails.join(','), subject: "New user registration at YouTube Tonight")
  end
end
