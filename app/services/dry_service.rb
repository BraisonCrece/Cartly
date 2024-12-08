# frozen_string_literal: true

class DryService
  extend Dry::Initializer
  include Dry::Monads[:result, :do, :maybe, :try]

  class << self
    # Instantiates and calls the service at once
    def call(*args, &block)
      new(*args).call(&block)
    end

    # Accepts both symbolized and stringified attributes
    def new(*args)
      hsh = args.pop.symbolize_keys if args.last.is_a?(Hash)
      super(*args, **(hsh || {}))
    end
  end
end
