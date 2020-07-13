require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
      password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = ("a" * 244) + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid emails" do
    valid_emails = %w(user@example.com USER@foo.COM A_US-ER@foo.bar.org 
                      first.last@foo.jp michael+lana@baz.cn)
    valid_emails.each do |valid_email|
      @user.email = valid_email
      assert @user.valid?, "#{valid_email.inspect} should be valid"
    end
  end

  test "email validation should reject invalid emails" do
    invalid_emails = %w(user@example,com user_at_foo.org user.name@example. 
                        foo@bar_baz.com foo@bar+baz.com foo@bar..com)
    invalid_emails.each do |invaild_email|
      @user.email = invaild_email
      assert_not @user.valid?, "#{invaild_email.inspect} should be invalid"
    end
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email should be saved as lower-case" do 
    mixed_case_email = "Foo@ExAmple.coM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present" do
    @user.password = @user.password_confirmation = "" * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "assosiated micropost should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow users" do
    michael = users(:user_5)
    lana = users(:user_6)

    lana.follow(michael)
    assert lana.following?(michael), 'lana should follow michael'

    assert michael.followers.include?(lana)

    lana.unfollow(michael)
    assert_not lana.following?(michael), 'lana should not follow michael'
    assert_not michael.following?(lana), 'michael should not follow lana'
  end

  test "feed should have the right posts" do
    alice = users(:alice)
    user_3 = users(:user_3)

    user_3.microposts.each do |post_following|
      assert alice.feed.include?(post_following)
    end

    alice.microposts.each do |post_self|
      assert alice.feed.include?(post_self)
    end

    alice.microposts.each do |post_unfollowed|
      assert_not user_3.feed.include?(post_unfollowed)
    end
  end

end
