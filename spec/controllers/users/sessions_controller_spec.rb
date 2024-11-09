require "rails_helper"

RSpec.describe Restaurants::SessionsController, type: :controller do
  it "shows the restaurant log in page" do
    @request.env["devise.mapping"] = Devise.mappings[:restaurant]
    get :new
    expect(response).to have_http_status(:ok)
  end

  it "allows the restaurant's sign_in action" do
    @request.env["devise.mapping"] = Devise.mappings[:restaurant]
    # post :create, params: { restaurant: { email: restaurant.email, password: restaurant.password } }
    restaurant = create(:restaurant)
    sign_in restaurant
    expect(response).to have_http_status(:ok)
    expect(subject.current_restaurant).to_not be_nil
  end
end
