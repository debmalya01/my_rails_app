require "test_helper"

class GarageBookingControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get garage_booking_index_url
    assert_response :success
  end

  test "should get edit" do
    get garage_booking_edit_url
    assert_response :success
  end

  test "should get update" do
    get garage_booking_update_url
    assert_response :success
  end
end
