class TagTopic < ApplicationRecord
  validates :topic, uniqueness: true, presence: true

  has_many :taggings,
    primary_key: :id,
    foreign_key: :tag_topic_id,
    class_name: 'Tagging'

  has_many :tagged_urls,
    -> { distinct },
    through: :taggings,
    source: :tagged_url

  has_many :visits,
    through: :tagged_urls,
    source: :visits

  has_many :tag_visits,
    through: :visits,
    source: :visited_url

  def popular_links
    tag_visits.all.group("short_url").limit(5).count
  end
end