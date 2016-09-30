class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  mount_uploader :avatar, AvatarUploader
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :friendships
  has_many :friends, :through => :friendships

  validates_integrity_of  :avatar
  validates_processing_of :avatar

  def add_friend(friend)
    friendship = friendships.build(:friend_id => friend.id)
    if !friendship.save
      logger.debug "User #{friend.email} already exists in the user's friendship list."
    end
  end
  
  def is_friend_of(user)
    self.friends.include? user
  end
  
  def all_message
    Message.where("user_id in (:friends, :id)", {:friends => friends.map(&:id), :id => self.id}).order(:created_at)
  end
  
  def followers
    followers_ids = Friendship.where("friend_id = :mine",{:mine => self.id}).map { |f|  f.user_id  }
    User.where("id in(:followers_ids)", {:followers_ids => followers_ids})
  end

  private
    def avatar_size_validation
      errors[:avatar] << "should be less than 500KB" if avatar.size > 0.5.megabytes
    end
end
