Stripe.api_key = Rails.application.credentials.stripe[:private_key]

class PaymentIncomplete < StandardError
  attr_reader :payment_intent

  def initialize(payment_intent, message)
    @payment_intent = payment_intent
    super(message)
  end
end

StripeEvent.signing_secret =
  ENV.fetch('stripe_signing_secret', false) ||
  Rails.application.credentials.stripe[:signing_secret]

StripeEvent.configure do |events|
  events.subscribe 'charge.succeeded', ChargeSucceededWebhook
  events.subscribe 'charge.refunded', ChargeRefundedWebhook
  events.subscribe 'customer.subscription.updated', SubscriptionUpdatedWebhook
  events.subscribe 'customer.subscription.deleted', SubscriptionDeletedWebhook
  events.subscribe 'invoice.payment_action_required', PaymentActionRequiredWebhook
end
