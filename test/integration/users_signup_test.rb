require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: {
        user: {
          name: "", 
          email: "user@invalid", 
          password: "foo", 
          password_confirmation: "bar"
        }
      }
    end

    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert', "The form contains 4 errors"
    assert_select 'div.field_with_errors'
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: {
        user: {
          name: "Example User",
          email: "user@example.com",
          password: "example",
          password_confirmation: "example"
        }
      }
    end

    assert_equal(1, ActionMailer::Base.deliveries.size, 'One email should have been sent')
    user = assigns(:user)
    # Invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: "wrong")
    assert_not is_logged_in?
    # Valid activation token, valid email
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

end
