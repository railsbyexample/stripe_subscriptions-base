class Charge < ApplicationRecord
  belongs_to :user

  scope :sorted, ->{ order(created_at: :desc) }
  default_scope ->{ sorted }

  def filename
    "receipt-#{created_at.strftime('%Y-%m-%d')}.pdf"
  end

  def receipt
    Receipts::Receipt.new(
      id: id,
      product: 'My Product',
      company: {
        name: 'Example, LLC',
        address: "1234 Bourbon Street\nNew York, NY\nUnited States",
        email: 'support@example.com'
      },
      line_items: line_items
    )
  end

  def line_items
    line_items = [
      ['Date', created_at.to_s],
      ['Account Billed', "#{user.name} (#{user.email})"],
      ['Product', 'My Product'],
      ['Amount', ApplicationController.helpers.formatted_amount(amount)],
      ['Charged to', "#{card_brand} ending in #{card_last4}"]
    ]

    if amount_refunded?
      line_items << [
        'Amount refunded',
        ApplicationController.helpers.formatted_amount(amount_refunded)
      ]
    end

    line_items
  end

  def refund(amount: nil)
    Stripe::Refund.create(charge: stripe_id, amount: amount)
    update(amount_refunded: amount)
  end
end
