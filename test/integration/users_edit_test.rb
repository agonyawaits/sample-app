require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:alice)
  end

  test "unsuccessful edit" do
    post_login_path(@user.email)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: {
      user: {
          name: "",
          email: "foo@invalid",
          password: "foo",
          password_confirmation: "bar"
      }
    }
    assert_template 'users/edit'
    assert_select 'div.alert', "The form contains 4 errors"
  end

  test "successful edit" do
    post_login_path(@user.email)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "New Name"
    email = "newvalidemail@example.com"
    patch user_path(@user), params: {
        user: {
            name: name,
            email: email,
            password: "",
            password_confirmation: ""
        }
    }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal email, @user.email
    assert_equal name, @user.name
  end

  test "friendly redirect to edit after logging in" do
    get edit_user_path(@user)
    assert_redirected_to login_path
    assert_not flash.empty?
    post_login_path(@user.email)
    assert_redirected_to edit_user_path(@user)
    assert_nil session[:forwarding_url]
  end

end
