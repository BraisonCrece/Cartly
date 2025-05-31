# frozen_string_literal: true

class TestMailer < ApplicationMailer
  def test_email(to_email = 'test@example.com')
    @subject = 'Test Email from Cartly'
    @message = 'This is a test email to verify SMTP configuration with Brevo.'

    mail(
      to: to_email,
      subject: @subject
    )
  end
end
