class Response < ApplicationRecord
  validate :not_duplicate_response, :not_own_poll

  def not_duplicate_response
    if response_already_answered?
      errors.add(:user_id, "cannot add two responses to the same question")
    end
  end

  def response_already_answered?
    self.sibling_responses.exists?(['responses.user_id = ?', self.user_id])
  end

  def sibling_responses
    self.question.responses.where.not(id: self.id)
  end

  def own_poll?
    self.user_id == self.question.poll.user_id
  end

  def not_own_poll
    if own_poll?
      errors.add(:user_id, "cannot respond to their own poll")
    end
  end

  belongs_to :answer_choice,
    primary_key: :id,
    foreign_key: :answer_choice_id,
    class_name: 'AnswerChoice'

  has_one :respondent,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: 'User'

  has_one :question,
    through: :answer_choice,
    source: :question

  # has_one :poll,
  #   through: :question,
  #   source: :poll
  # does not work properly due to Rails bug?
end