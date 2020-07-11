class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validate :check_follower_id_does_not_equal_folllowed_id

  private
  def check_follower_id_does_not_equal_folllowed_id
    errors.add(:followed_id, "can't be the same as follower id") if follower_id == followed_id
  end
end
