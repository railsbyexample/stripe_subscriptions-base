class PaymentActionRequiredPreview < ActionMailer::Preview
  def payment_action_required
    user = User.new(email: "test@test.com", name: "Test User")
    subscription = Subscription.new
    payment_intent = Stripe::PaymentIntent.retrieve("pi_1FcuVGKXBGcbgpbZ3Kc6PvBq")

    UserMailer.payment_action_required(user, payment_intent, subscription)
  end
end
