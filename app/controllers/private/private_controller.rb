# frozen_string_literal: true

module Private
  class PrivateController < ApplicationController
    before_action :authenticate_restaurant!
  end
end
