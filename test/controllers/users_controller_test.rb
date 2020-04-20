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

end
