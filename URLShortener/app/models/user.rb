class User < ApplicationRecord
  validates :email, uniqueness: true, presence: true

  has_many :submitted_urls,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: 'ShortenedUrl'

  has_many :visits,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: 'Visit'

  has_many :visited_urls,
    -> { distinct },
    through: :visits,
    source: :visited_url

  def visit!(shortened_url)
    Visit.create!(
      user_id: self.id,
      url_id: shortened_url.id,
    )
  end
end