if Rails.env.development?
  LetterOpenerWeb.configure do |config|
    config.letters_location = Rails.root.join('tmp', 'letter_opener_web')
  end
end
