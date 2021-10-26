class AnswerChoice < ApplicationRecord
  validates :text, uniqueness: {
    scope: :question_id,
    message: 'must be different for each answer choice to a given question',
  }

  belongs_to :question,
    primary_key: :id,
    foreign_key: :question_id,
    class_name: 'Question'

  has_many :responses,
    primary_key: :id,
    foreign_key: :answer_choice_id,
    class_name: 'Response',
    dependent: :destroy
end