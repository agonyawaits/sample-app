require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:alice)
    @non_admin = users(:bob)
    @unactivated_user = users(:unactivated_user)
  end

  test "index as admin has delete links and has no unactivated users" do
    post_login_path(@admin.email)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'

    User.paginate(page: 1).each do |user|
      if user.activated?
        assert_select 'a[href=?]', user_path(user), text: user.name
        unless user == @admin
          assert_select 'a[href=?]', user_path(user), text: 'Delete'
        end
      else
        assert_select 'a[href=?]', user_path(user), false
      end
    end

    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin has no unactivated users" do
    post_login_path(@non_admin.email)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'

    User.paginate(page: 1).each do |user|
      if user.activated?
        assert_select 'a[href=?]', user_path(user), text: user.name
      else
        assert_select 'a[href=?]', user_path(user), false
      end
    end
  end

  test "index as non-admin" do
    post_login_path(@non_admin)
    get users_path
    assert_select 'a', text: "Delete", count: 0
  end

end
