require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.update_card("pm_card_visa")
    @subscription = @user.subscribe("small-monthly")
  end

  test "swapping plan" do
    @subscription.swap("large-monthly")
    assert_equal "large-monthly", @subscription.stripe_plan
  end

  test "cancel subscription" do
    @subscription.cancel
    assert @subscription.canceled?
    assert @subscription.on_grace_period?
  end

  test "cancel subscription immediately" do
    @subscription.cancel_now!
    assert @subscription.canceled?
    assert_not @subscription.on_grace_period?
  end

  test "resume subscription" do
    @subscription.cancel
    @subscription.resume
    assert_not @subscription.canceled?
    assert @subscription.active?
  end

  test "cannot resume subscription that's outside the grace period" do
    @subscription.cancel_now!
    assert_raises StandardError do
      @subscription.resume
    end
  end
end
