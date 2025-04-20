# frozen_string_literal: true

module NotificationHelper
  def turbo_notification(message, type: :notice)
    turbo_stream.prepend(
      'notifications',
      partial: 'shared/notification',
      locals: { message: message, type: type }
    )
  end
end
