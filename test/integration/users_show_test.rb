require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest

  def setup
    @activated_user = users(:alice)
    @unactivated_user = users(:unactivated_user)
  end

  test "should redirect to root url when user is not activated" do
    post_login_path(@unactivated_user.email)
    assert_redirected_to(root_url, 'Unactivated user should be redirected to root url')
  end

  test "should not redirect to root url when user is activated" do
    post_login_path(@activated_user.email)
    assert_redirected_to(@activated_user, 'Activated user should be redirected to profile page')
  end

end
