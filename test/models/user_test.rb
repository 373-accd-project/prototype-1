require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should validate_presence_of(:api_key)
  should validate_presence_of(:username)
  should validate_presence_of(:password).on(:create)
  should validate_presence_of(:password_confirmation).on(:create)

  should validate_length_of(:password).is_at_least(4)

  should validate_uniqueness_of(:username).case_insensitive

  should have_secure_password
end
