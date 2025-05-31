# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@gocartly.es'
  layout 'mailer'
end
