require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:alice)
  end
  
  test "login with valid information followed by logout" do
    # When
    post_login_path(@user.email)
    # Then
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    
    # When
    delete logout_path
    # Then
    assert_not is_logged_in?
    assert_redirected_to root_url
  end

  test "login with valid email / invalid password" do
    # When
    post_login_path(@user.email, password: "invalid")
    # Then
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with invalid information" do
    # When
    post_login_path("invalid@example.com")
    # Then
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with/without remembering" do
    # When
    post_login_path(@user.email, remember_me: '1')
    # Then
    assert_not_empty cookies[:remember_token]

    # When
    post_login_path(@user.email, remember_me: '0')
    # Then
    assert_empty cookies[:remember_token]
  end

end
