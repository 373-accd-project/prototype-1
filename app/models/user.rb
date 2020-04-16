class User < ApplicationRecord
  has_secure_password

  # Both password and confirmation required on creation
  validates :password, presence: true, confirmation: true, on: :create
  validates :password, length: { minimum: 4, message: "must be at least 4 characters long"}, on: :create
  validates :password_confirmation, presence: true, on: :create

  # Conditional password validation on updates
  with_options if: Proc.new { |a| a.password.present? } do |admin|
    admin.validates :password, length: { minimum: 4, message: "must be at least 4 characters long"}
    admin.validates :password_confirmation, presence: true
  end

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :api_key, presence: true
  validates :admin, inclusion: { in: [true, false] }
end
