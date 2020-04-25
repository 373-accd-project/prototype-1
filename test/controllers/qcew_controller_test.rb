require 'test_helper'

class QcewControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "goes to home if not logged in" do
    get "/qcew"
    assert_redirected_to "/login"
  end
end
