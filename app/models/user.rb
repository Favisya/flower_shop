class User < ApplicationRecord
  belongs_to :role
  has_secure_password
  has_secure_password :recovery_password, validations: false
  validates :name,:surname,:login,:email, presence: true
  self.primary_key = :id
  validates :id, :login, :email, uniqueness: true
end
