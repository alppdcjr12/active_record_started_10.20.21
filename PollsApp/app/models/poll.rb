class Poll < ApplicationRecord
  validates :title, uniqueness: {
    scope: :user_id,
    message: 'must be different for each poll created by a given user',
  }

  belongs_to :author,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: 'User'

  has_many :questions,
    primary_key: :id,
    foreign_key: :poll_id,
    class_name: 'Question',
    dependent: :destroy

end