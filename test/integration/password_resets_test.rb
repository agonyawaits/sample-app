require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:alice)
  end

  test "password reset" do
    get new_password_reset_path
    assert_template 'password_resets/new', 'Wrong template was rendered'
    assert_select 'input[name=?]', 'password_reset[email]'

    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?, 'Flash should not be empty'
    assert_template 'password_resets/new'

    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest, 'Reset digest was not updated'
    assert_equal 1, ActionMailer::Base.deliveries.size, 'Email was not sent'
    assert_not flash.empty?, 'Flash should not be empty'
    assert_redirected_to root_url

    user = assigns(:user)
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url

    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url

    user.toggle!(:activated)
    get edit_password_reset_path("wrong token", email: user.email)
    assert_redirected_to root_url

    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit', 'Wrong template was rendered'
    assert_select "input[name=email][type=hidden][value=?]", user.email

    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: "foobar", password_confirmation: "foobar" } }
    assert is_logged_in?, 'User should be logged in after resetting a password'
    assert_not flash.empty?, 'Flash should not be empty'
    assert_redirected_to user
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path, params: { password_reset: { email: @user.email } }
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token), params: { email: @user.email, user: { password: "foobar", password_confirmation: "foobar" } }
    follow_redirect!
    assert_match "Password reset has expired", response.body, 'Message informing about reset expiration should be displayed'
  end
end
