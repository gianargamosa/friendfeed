class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :friendships
  has_many :friends, :through => :friendships

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
end
