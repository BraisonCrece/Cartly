# frozen_string_literal: true

# Helper para traducir los textos
module TranslateHelper
  def translate(i18n, active_record = nil)
    return active_record if I18n.locale == :es

    I18n.t(i18n)
  end

  def build_link(object, restaurant_id)
    polymorphic_path(object, restaurant_id: restaurant_id, locale: I18n.locale)
  end

  def locale_flag(locale = nil)
    current_locale = (locale || I18n.locale).to_sym
    Rails.application.config.locale_flags[current_locale] || 'spain.png'
  end
end
