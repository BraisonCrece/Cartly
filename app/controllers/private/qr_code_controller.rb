# frozen_string_literal: true

# This controller is responsible for generating QR codes for the restaurant's menu
module Private
  class QrCodeController < ApplicationController
    # Generates a QR code, and returns the image asset to download
    # http://#{host}/#{restaurant_id}/qr
    def generate
      host_url = Rails.application.config.action_controller.default_url_options[:host]
      url = qr_url(restaurant_id: current_restaurant.id, host: host_url)
      qr_code = ::RQRCode::QRCode.new(url)

      send_data qr_code.as_png(size: 1000),
                type: 'image/png',
                disposition: 'attachment',
                filename: 'qr_code.png'
    end
  end
end
