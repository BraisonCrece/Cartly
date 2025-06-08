# frozen_string_literal: true

module Webhooks
  class StripeController < ActionController::Base
    skip_before_action :verify_authenticity_token

    def webhook
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      event = nil

      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, Rails.application.config.stripe[:webhook_secret]
        )
      rescue JSON::ParserError
        render json: { error: 'Invalid payload' }, status: 400
        return
      rescue Stripe::SignatureVerificationError
        render json: { error: 'Invalid signature' }, status: 400
        return
      end

      # Handle the event
      case event['type']
      when 'customer.subscription.created'
        handle_subscription_created(event['data']['object'])
      when 'customer.subscription.updated'
        handle_subscription_updated(event['data']['object'])
      when 'customer.subscription.deleted'
        handle_subscription_deleted(event['data']['object'])
      when 'invoice.payment_succeeded'
        handle_payment_succeeded(event['data']['object'])
      when 'invoice.payment_failed'
        handle_payment_failed(event['data']['object'])
      when 'customer.subscription.trial_will_end'
        handle_trial_will_end(event['data']['object'])
      else
        Rails.logger.info "Unhandled event type: #{event['type']}"
      end

      render json: { received: true }, status: 200
    end

    private

    def handle_subscription_created(subscription)
      restaurant = find_restaurant_by_customer(subscription['customer'])
      return unless restaurant

      restaurant.update!(
        stripe_subscription_id: subscription['id'],
        subscription_status: subscription['status'],
        subscription_current_period_end: Time.at(subscription['current_period_end'])
      )

      Rails.logger.info "Subscription created for restaurant #{restaurant.id}"
    end

    def handle_subscription_updated(subscription)
      restaurant = find_restaurant_by_customer(subscription['customer'])
      return unless restaurant

      restaurant.update!(
        subscription_status: subscription['status'],
        subscription_current_period_end: Time.at(subscription['current_period_end'])
      )

      Rails.logger.info "Subscription updated for restaurant #{restaurant.id}: #{subscription['status']}"
    end

    def handle_subscription_deleted(subscription)
      restaurant = find_restaurant_by_customer(subscription['customer'])
      return unless restaurant

      restaurant.update!(
        subscription_status: 'canceled',
        subscription_current_period_end: Time.at(subscription['current_period_end'])
      )

      Rails.logger.info "Subscription deleted for restaurant #{restaurant.id}"
    end

    def handle_payment_succeeded(invoice)
      return unless invoice['subscription']

      subscription = Stripe::Subscription.retrieve(invoice['subscription'])
      restaurant = find_restaurant_by_customer(subscription['customer'])
      return unless restaurant

      # Update subscription status and period end
      restaurant.update!(
        subscription_status: subscription['status'],
        subscription_current_period_end: Time.at(subscription['current_period_end'])
      )

      Rails.logger.info "Payment succeeded for restaurant #{restaurant.id}"
    end

    def handle_payment_failed(invoice)
      return unless invoice['subscription']

      subscription = Stripe::Subscription.retrieve(invoice['subscription'])
      restaurant = find_restaurant_by_customer(subscription['customer'])
      return unless restaurant

      restaurant.update!(
        subscription_status: subscription['status'],
        subscription_current_period_end: Time.at(subscription['current_period_end'])
      )

      Rails.logger.info "Payment failed for restaurant #{restaurant.id}"
    end

    def handle_trial_will_end(subscription)
      restaurant = find_restaurant_by_customer(subscription['customer'])
      return unless restaurant

      # Could send notification email here
      Rails.logger.info "Trial ending soon for restaurant #{restaurant.id}"
    end

    def find_restaurant_by_customer(customer_id)
      restaurant = Restaurant.find_by(stripe_customer_id: customer_id)
      
      unless restaurant
        Rails.logger.error "Restaurant not found for Stripe customer: #{customer_id}"
      end
      
      restaurant
    end
  end
end