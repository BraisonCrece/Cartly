# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def provinces
    Carmen::Country.named('Spain').subregions.map(&:subregions).flatten.map(&:name)
  end
end
