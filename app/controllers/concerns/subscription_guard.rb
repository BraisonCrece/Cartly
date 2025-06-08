# frozen_string_literal: true

module SubscriptionGuard
  extend ActiveSupport::Concern

  included do
    before_action :check_subscription_status
    helper_method :subscription_warning_message, :subscription_blocked?, :subscription_expired_recently?
  end

  private

  def check_subscription_status
    return unless current_restaurant

    @subscription_status = current_restaurant.subscription_status
    @subscription_expired = current_restaurant.subscription_expired?
    @subscription_inactive = current_restaurant.subscription_inactive?
    @has_valid_subscription = current_restaurant.has_valid_subscription?
  end

  def require_active_subscription!
    return if current_restaurant&.has_valid_subscription?

    redirect_to_subscription_required
  end

  def block_write_actions!
    return if current_restaurant&.has_valid_subscription?

    return unless request.post? || request.patch? || request.put? || request.delete?

    respond_to_blocked_action
  end

  def subscription_blocked?
    !@has_valid_subscription
  end

  def subscription_expired_recently?
    return false unless current_restaurant&.subscription_expired?

    current_restaurant.subscription_current_period_end&.> 7.days.ago
  end

  def subscription_warning_message
    return nil if @has_valid_subscription

    case @subscription_status
    when 'past_due'
      'Tu suscripción tiene pagos pendientes. Actualiza tu método de pago para continuar.'
    when 'canceled'
      'Tu suscripción ha sido cancelada. Renueva para seguir utilizando todas las funcionalidades.'
    when 'inactive', nil
      'No tienes una suscripción activa. Suscríbete para acceder a todas las funcionalidades.'
    else
      subscription_expired_message
    end
  end

  def subscription_expired_message
    return nil unless @subscription_expired

    days_expired = (Date.current - current_restaurant.subscription_current_period_end.to_date).to_i
    day_word = days_expired == 1 ? 'día' : 'días'

    if days_expired <= 7
      "Tu suscripción expiró hace #{days_expired} #{day_word}. Renueva pronto o tu carta será eliminada."
    else
      'Tu suscripción ha expirado. Renueva para evitar que tu carta sea eliminada.'
    end
  end

  def grace_period_active?
    return false unless current_restaurant&.subscription_expired?

    current_restaurant.subscription_current_period_end > 30.days.ago
  end

  def redirect_to_subscription_required
    redirect_to(
      control_panel_products_path,
      alert: 'Necesitas una suscripción activa para acceder a esta funcionalidad.'
    )
  end

  def respond_to_blocked_action
    message = 'Esta acción requiere una suscripción activa.'

    render turbo_stream: turbo_notification(message)
  end

  def redirect_back_or_to(default_path)
    if request.referer.present? && request.referer != request.url
      redirect_back(fallback_location: default_path)
    else
      redirect_to default_path
    end
  end
end
