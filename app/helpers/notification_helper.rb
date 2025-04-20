# frozen_string_literal: true

module NotificationHelper
  def turbo_notification(message, type: :notice)
    turbo_stream.prepend(
      "#{current_restaurant&.id || 'default'}_notifications",
      partial: 'shared/notification',
      locals: { message: message, type: type }
    )
  end
end
