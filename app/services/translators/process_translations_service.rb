# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Translators
  class ProcessTranslationsService
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do

    attr_reader :item, :method

    def initialize(item, method)
      @item = item
      @method = method
    end

    def call
      yield process_item_translations
    end

    private

    def process_item_translations
      case method
      when :create, :update
        Translators::NewItemTranslatorService.new(item).call
      else
        Failure('Method not found')
      end
    end
  end
end
