class CardsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @setup_intent = current_user.create_setup_intent
  end

  def update
    current_user.update_card(params[:payment_method_id])
    redirect_to edit_card_path, notice: 'Your card was successfully updated'
  rescue Stripe::Error => e
    redirect_to edit_card_path, alert: "Card error: #{e.message}"
  end
end
