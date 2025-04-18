class SubscriptionUpdatedWebhook
  def self.call(*args)
    new(*args).call
  end

  def initialize(event)
    @object = event.data.object
    @subscription = Subscription.find_by(stripe_id: object.id)
  end

  def call
    return if subscription.nil?

    if object.status == 'incomplete_expired'
      subscription.destroy
      return
    end

    subscription.status = object.status
    subscription.trial_ends_at = Time.at(object.trial_end) if object.trial_end

    if object.ended_at
      subscription.ends_at = Time.at(object.ended_at)
    elsif object.cancel_at
      subscription.ends_at = Time.at(object.cancel_at)
    end

    subscription.save
  end

  private

  attr_reader :object, :subscription
end
