class ChargeSucceededWebhook
  def self.call(*args)
    new(*args).call
  end

  def initialize(event)
    @object = event.data.object
    @user = User.find_by(stripe_id: object.customer)
  end

  def call
    return if user.nil?
    return if user.charges.where(stripe_id: object.id).any?

    create_charge
  end

  private

  attr_reader :object, :user

  def create_charge
    user.charges.create({
      stripe_id: object.id,
      amount: object.amount,
      created_at: Time.at(object.created)
    }.merge(card_info))
  end

  def card_info
    card = object.payment_method_details.card
    %i[brand last4 exp_month exp_year].map do |attr|
      ["card_#{attr}".to_sym, card.send(attr)]
    end.to_h
  end
end
