class Tagging < ApplicationRecord
  validates :url_id, :tag_topic_id, presence: true

  def self.add_tag!(url, tag_topic)
    Tagging.create!(
      url_id: url.id,
      tag_topic_id: tag_topic.id,
    )
  end

  belongs_to :tagged_url,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: 'ShortenedUrl'

  belongs_to :url_tag,
    primary_key: :id,
    foreign_key: :tag_topic_id,
    class_name: 'TagTopic'
end