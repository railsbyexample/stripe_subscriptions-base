class ChargeRefundedWebhook
  def self.call(*args)
    new(*args).call
  end

  def initialize(event)
    @object = event.data.object
    @user = User.find_by(stripe_id: object.customer)
    @charge = user.charges.find_by(stripe_id: object.id)
  end

  def call
    return if user.nil?
    return if charge.nil?

    charge.update(amount_refunded: object.amount_refunded)
  end

  private

  attr_reader :object, :user, :charge
end
