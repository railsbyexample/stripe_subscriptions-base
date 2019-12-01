class PaymentActionRequiredWebhook
  def self.call(*args)
    new(*args).call
  end

  def initialize(event)
    @object = event.data.object
    @user = User.find_by(stripe_id: object.customer)
    @subscription = Subscription.find_by(stripe_id: object.subscription)
  end

  def call
    return if user.nil? || subscription.nil?

    payment_intent = Stripe::PaymentIntent.retrieve(object.payment_intent)

    UserMailer.payment_action_required(user, payment_intent, subscription)
  end

  private

  attr_reader :object, :user, :subscription
end
