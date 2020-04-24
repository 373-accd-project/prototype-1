require 'test_helper'

class OesControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "goes to home if not logged in" do
    get "/oes"
    assert_redirected_to "/login"
  end
end
