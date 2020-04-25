require 'test_helper'

class LaunempControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "goes to home if not logged in" do
    get "/launemp"
    assert_redirected_to "/login"
  end
end
