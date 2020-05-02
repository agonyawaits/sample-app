require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:alice)
    @another_user = users(:bob)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: {
        user: {
            email: @user.email,
            name: @user.name
        }
    }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as different user" do
    post_login_path(@user.email)
    get edit_user_path(@another_user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect user delete when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect user delete to root url when not admin" do
    post_login_path(@another_user.email)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    post_login_path(@another_user.email)
    assert_not @another_user.admin?
    patch user_path(@another_user), params: {
        user: {
            password: "password",
            password_confirmation: "password",
            admin: true
        }
    }
    assert_not @another_user.reload.admin?
  end

  test "delete user" do
    post_login_path(@user.email)
    assert_difference 'User.count', -1 do
      delete user_path(@another_user)
    end
  end
end
