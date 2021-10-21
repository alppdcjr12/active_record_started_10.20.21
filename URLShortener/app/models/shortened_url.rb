require 'SecureRandom'

class ShortenedUrl < ApplicationRecord
  validates :long_url, :short_url, :user_id, presence: true
  validates :long_url, uniqueness: {
    scope: :user_id,
    message: 'should only be added once per user',
  }
  validate :no_spamming
  validate :nonpremium_max
  
  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: 'User'

  has_many :visits,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: 'Visit',
    dependent: :destroy

  has_many :visitors,
    -> { distinct },
    through: :visits,
    source: :visitor

  has_many :taggings,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: 'Tagging',
    dependent: :destroy

  has_many :tag_topics,
    -> { distinct },
    through: :taggings,
    source: :url_tag

  def self.random_code
    while true
      code = SecureRandom::urlsafe_base64
      return code unless ShortenedUrl.exists?(['short_url LIKE ?', '%#{code}%'])
    end
  end

  def self.create_for_user_and_long_url!(user, long_url)
    short_url = 'www.mywebsite.com/code=' + random_code
    ShortenedUrl.create!(
      long_url: long_url,
      short_url: short_url,
      user_id: user.id
    )
  end

  def self.prune(n)
    self.not_visited_in(n).destroy_all
  end
  
  def self.not_visited_in(n)
    n_minutes_ago = n.minutes.ago
    ShortenedUrl
      .joins("LEFT JOIN 'visits' ON 'visits'.'url_id' = 'shortened_urls'.'id'")
      .joins("LEFT JOIN 'users' ON 'visits'.'user_id' = 'users'.'id'")
      .group(:short_url)
      .where("'shortened_urls'.'created_at' < ?", n_minutes_ago)
      .where("'users'.'premium' = ?", false)
      .having(
        "max(visits.created_at) < ? OR visits.created_at IS NULL",
        n_minutes_ago
      )
  end

  def no_spamming
    if num_links_last_minute(self.user_id) > 4
      errors.add(:created_at, 'can\'t be within one minute of the four or more most recently submitted links')
    end
  end

  def nonpremium_max
    current_user = User.find(self.user_id)
    unless current_user.premium
      if num_links_by_user(self.user_id) >= 5
        errors.add(:premium, 'must be true for user to submit more than 5 urls')
      end
    end
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end
  
  def num_recent_uniques
    visits.select(:user_id).distinct.where(url_id: self.id, created_at: (10.minutes.ago)..Time.now).count
  end
  
  def num_links_last_minute(user_id)
    ShortenedUrl.where(user_id: user_id, created_at: (1.minutes.ago)..Time.now).count
  end

  def num_links_by_user(user_id)
    ShortenedUrl.where(user_id: user_id).count
  end

  def add_tag!(tag_topic)
    Tagging.create!(
      url_id: self.id,
      tag_topic_id: tag_topic.id,
    )
  end

end