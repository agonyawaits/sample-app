require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @relationship = Relationship.new(follower_id: users(:alice).id, followed_id: users(:bob).id)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end

  test "follower_id and followed_id can't be the same" do
    @relationship.followed_id = @relationship.follower_id
    assert_not @relationship.valid?
  end
end
