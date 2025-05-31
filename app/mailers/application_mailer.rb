# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: '8e73c2001@smtp-brevo.com'
  layout 'mailer'
end
