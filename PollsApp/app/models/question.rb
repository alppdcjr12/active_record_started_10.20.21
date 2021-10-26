class Question < ApplicationRecord
  validates :text, uniqueness: {
    scope: :poll_id,
    message: 'must be different for each question in a given poll',
  }

  has_many :answer_choices,
    primary_key: :id,
    foreign_key: :question_id,
    class_name: 'AnswerChoice',
    dependent: :destroy

  belongs_to :poll,
    primary_key: :id,
    foreign_key: :poll_id,
    class_name: 'Poll'

  has_many :responses,
    through: :answer_choices,
    source: :responses,
    dependent: :destroy

  def results
    answer_choices
      .select('answer_choices.*', 'COUNT(responses.id) AS total_votes')
      .left_outer_joins(:responses)
      .group('answer_choices.id')
  end
end