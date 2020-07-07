require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    user = users(:alice)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject, "Mail subject is invalid"
    assert_equal [user.email], mail.to, "Invalid to address"
    assert_equal ["4468120@gmail.com"], mail.from, "Invalid from address"
    assert_match user.name, mail.body.encoded, "Email does not contain user name"
    assert_match user.activation_token, mail.body.encoded, "Activation link has invalid activation token"
    assert_match CGI.escape(user.email), mail.body.encoded, "Activation link has invalid email"
  end

  test "reset password" do
    user = users(:alice)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "Password reset", mail.subject, "Mail subject is invalid"
    assert_equal [user.email], mail.to, "Invalid to address"
    assert_equal ["4468120@gmail.com"], mail.from, "Invalid from address"
    assert_match user.reset_token, mail.body.encoded, "Reset link has invalid reset token"
    assert_match CGI.escape(user.email), mail.body.encoded, "Reset link has invalid email"
  end

end
