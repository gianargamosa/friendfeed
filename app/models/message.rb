class Message < ApplicationRecord
  after_create_commit { BroadcastMessageJob.perform_later self  }
  belongs_to :user
  after_initialize :init

  def init
    self.created_at ||= Time.now
  end
end
