OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_KEY")
  config.log_errors = true if Rails.env.development?
end