# frozen_string_literal: true

class SubscriptionsController < AdminController
  before_action :authenticate_restaurant!

  def show
    @restaurant = current_restaurant
    @subscription_status = @restaurant.subscription_status
    @current_period_end = @restaurant.subscription_current_period_end
    @stripe_customer_id = @restaurant.stripe_customer_id
  end

  def new
    redirect_to subscription_path if current_restaurant.has_valid_subscription?
  end

  def create
    customer_id = current_restaurant.create_stripe_customer

    checkout_session = Stripe::Checkout::Session.create(
      {
        customer: customer_id,
        payment_method_types: ['card'],
        line_items: [{
          price: ENV.fetch('STRIPE_PRICE_ID'), # Monthly subscription price ID
          quantity: 1,
        }],
        mode: 'subscription',
        success_url: success_subscription_url,
        cancel_url: cancel_subscription_url,
        metadata: {
          restaurant_id: current_restaurant.id,
        },
      }
    )

    redirect_to checkout_session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    flash[:alert] = "Error al procesar el pago: #{e.message}"
    redirect_to new_subscription_path
  end

  def success
    flash[:notice] = 'Tu suscripción se ha activado correctamente. ¡Bienvenido!'
    redirect_to control_panel_products_path
  end

  def cancel
    flash[:alert] = 'El proceso de suscripción fue cancelado. Puedes intentarlo de nuevo cuando quieras.'
    redirect_to new_subscription_path
  end

  def cancel_subscription
    return unless current_restaurant.stripe_subscription_id

    begin
      Stripe::Subscription.update(
        current_restaurant.stripe_subscription_id,
        { cancel_at_period_end: true }
      )

      flash[:notice] = 'Tu suscripción se cancelará al final del período actual.'
      redirect_to subscription_path
    rescue Stripe::StripeError => e
      flash[:alert] = "Error al cancelar la suscripción: #{e.message}"
      redirect_to subscription_path
    end
  end

  def reactivate
    return unless current_restaurant.stripe_subscription_id

    begin
      Stripe::Subscription.update(
        current_restaurant.stripe_subscription_id,
        { cancel_at_period_end: false }
      )

      flash[:notice] = 'Tu suscripción ha sido reactivada.'
      redirect_to subscription_path
    rescue Stripe::StripeError => e
      flash[:alert] = "Error al reactivar la suscripción: #{e.message}"
      redirect_to subscription_path
    end
  end

  def billing_portal
    return unless current_restaurant.stripe_customer_id

    begin
      portal_session = Stripe::BillingPortal::Session.create(
        {
          customer: current_restaurant.stripe_customer_id,
          return_url: subscription_url,
        }
      )

      redirect_to portal_session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      flash[:alert] = "Error al acceder al portal de facturación: #{e.message}"
      redirect_to subscription_path
    end
  end

  private

  def subscription_params
    params.permit(:payment_method_id)
  end
end
