class UserMailer < ActionMailer::Base
  default from: "yttonight@gmail.com"

  def authorized_email(user)
    @user = user
    mail(to: @user.email, subject: "Huzzah! You are now approved on YouTube Tonight!")
  end
end
