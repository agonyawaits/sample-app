require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:alice)
  end

  test "index including pagination" do
    post_login_path(@user.email)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
  end

end
