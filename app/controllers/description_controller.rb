# frozen_string_literal: true

class DescriptionController < AdminController
  before_action :authenticate_restaurant!

  def describe_dish
    description = DescriptionService.new(
      plato: params[:plato],
      image: params[:image],
      type: params[:description_type] || 'plato'
    ).generate

    render json: { description: description }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
