require 'SecureRandom'

class ShortenedUrl < ApplicationRecord
  validates :long_url, :short_url, :user_id, presence: true
  validates :long_url, uniqueness: {
    scope: :user_id,
    message: 'should only be added once per user',
  }

  validate :no_spamming

  def no_spamming
    if num_links_last_minute(self.user_id) > 4
      errors.add(:created_at, 'can\'t be within one minute of the four or more most recently submitted links')
    end
  end

  validate :nonpremium_max

  def nonpremium_max
    current_user = User.find(self.user_id)
    unless current_user.premium
      if num_links_by_user(self.user_id) >= 5
        errors.add(:premium, 'must be true for user to submit more than 5 urls')
      end
    end
  end

  def self.random_code
    while true
      code = SecureRandom::urlsafe_base64
      return code unless ShortenedUrl.exists?(['short_url LIKE ?', '%#{code}%'])
    end
  end

  def self.from_user_and_url(user, long_url)
    short_url = 'www.mywebsite.com/code=' + random_code
    ShortenedUrl.create!(
      long_url: long_url,
      short_url: short_url,
      user_id: user.id
    )
  end

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: 'User'

  has_many :visits,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: 'Visit'

  has_many :visitors,
    -> { distinct },
    through: :visits,
    source: :visitor

  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end
  
  def num_recent_uniques
    visits.select(:user_id).distinct.where(url_id: self.id).where(created_at: (10.minutes.ago)..Time.now).count
  end
  
  def num_links_last_minute(user_id)
    ShortenedUrl.where(user_id: user_id).where(created_at: (1.minutes.ago)..Time.now).count
  end

  def num_links_by_user(user_id)
    ShortenedUrl.where(user_id: user_id).count
  end

  has_many :taggings,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: 'Tagging'

  has_many :tag_topics,
    -> { distinct },
    through: :taggings,
    source: :url_tag

end