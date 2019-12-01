class SubscriptionDeletedWebhook
  def self.call(*args)
    new(*args).call
  end

  def initialize(event)
    @object = event.data.object
    @subscription = Subscription.find_by(stripe_id: object.id)
  end

  def call
    return if subscription.nil?
    return unless subscription.ends_at.blank? && object.ended_at.present?

    subscription.update! ends_at: Time.at(object.ended_at)
  end

  private

  attr_reader :object, :subscription
end
