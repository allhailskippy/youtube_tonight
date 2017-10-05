require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "authorized email" do
    user = create(:user, email: 'test@email.com', name: 'Test Name')

    # Create the email and store it for further assertions
    email = UserMailer.authorized_email(user)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['yttonight@gmail.com'], email.from
    assert_equal "YouTube Tonight <yttonight@gmail.com>", email[:from].value
    assert_equal ["test@email.com"], email.to
    assert_equal "test@email.com", email[:to].value
    expected = "Huzzah! Your YouTube Tonight account has been approved!"
    assert_equal expected, email.subject
    assert_equal read_fixture('authorized_email.html').join, email.body.to_s
  end

  test 'registered_user' do
    # Clear out any existing users
    User.without_system_admin.delete_all

    user = create(:user, email: 'test@email.com', name: 'Test Name', role_titles: ['host'])
    admin = create(:user, role_titles: ['admin'], email: 'admin@email.com')

    # Create the email and store it for further assertions
    email = UserMailer.registered_user(user)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['yttonight@gmail.com'], email.from
    assert_equal "YouTube Tonight <yttonight@gmail.com>", email[:from].value
    assert_equal ["admin@email.com"], email.to
    assert_equal "admin@email.com", email[:to].value
    expected = "New user registration at YouTube Tonight"
    assert_equal expected, email.subject
    assert_equal read_fixture('registered_user.html').join, email.body.to_s
  end

  test 'registered_user - no admin users found' do
    # Clear out any existing users
    User.without_system_admin.delete_all

    user = create(:user, email: 'test@email.com', name: 'Test Name', role_titles: ['host'])

    # Create the email and store it for further assertions
    email = UserMailer.registered_user(user)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['yttonight@gmail.com'], email.from
    assert_equal "YouTube Tonight <yttonight@gmail.com>", email[:from].value
    assert_equal ["admin@example.com"], email.to
    assert_equal "admin@example.com", email[:to].value
    expected = "New user registration at YouTube Tonight"
    assert_equal expected, email.subject
    assert_equal read_fixture('registered_user.html').join, email.body.to_s
  end

  test 'registered_user - no users found' do
    # Clear out all existing users
    User.delete_all

    user = create(:user, email: 'test@email.com', name: 'Test Name', role_titles: ['host'])

    # Create the email and store it for further assertions
    email = UserMailer.registered_user(user)

    # Should trigger a handled exception
    NewRelic::Agent.expects(:notice_error).once
    assert_emails 0 do
      email.deliver_now
    end
  end
end
