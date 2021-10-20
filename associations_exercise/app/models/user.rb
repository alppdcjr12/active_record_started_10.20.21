class User < ApplicationRecord

  has_many :enrollments,
    class_name: 'Enrollment',
    primary_key: :id,
    foreign_key: :user_id
    
end
