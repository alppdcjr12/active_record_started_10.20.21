class Tagging < ApplicationRecord
  validates :url_id, :tag_topic_id, presence: true

  belongs_to :tagged_url,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: 'ShortenedUrl'

  belongs_to :url_tag,
    primary_key: :id,
    foreign_key: :tag_topic_id,
    class_name: 'TagTopic'
end