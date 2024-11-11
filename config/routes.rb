# frozen_string_literal: true

Rails.application.routes.draw do
  # public routes
  root 'dynamic_router#call'

  devise_for :restaurants, path: 'admin', path_names: { sign_in: 'sign_in', sign_out: 'sign_out', sign_up: 'sign_up' }, controllers: {
    sessions: 'restaurants/sessions',
    registrations: 'restaurants/registrations'
  }

  resources :allergens
  resources :dishes
  resources :special_menus
  resources :categories
  resources :wines
  resources :wine_types
  resources :wine_origin_denominations, as: :denominations, path: 'denominations'

  resources :settings, only: %i[edit update]

  get '/control_panel', to: 'control_panel#index'

  get '/wines_control_panel', to: 'wines#control_panel', as: :wines_control_panel
  post 'toggle_active/:dish_id', to: 'control_panel#toggle_active', as: :toggle_active
  post 'wine_toggle_active/:wine_id', to: 'wines#toggle_active', as: :wine_toggle_active
  post 'toggle_special_menu/:special_menu_id', to: 'special_menus#toggle_active', as: :toggle_special_menu
  post 'translate', to: 'translate#translate'
  post 'describe_dish', to: 'description#describe_dish'
  get ':restaurant_id/menu', to: 'dishes#menu', as: :menu
  get ':restaurant_id/carta', to: 'dishes#index', as: :carta
  get ':restaurant_id/pages_control', to: 'dishes#pages_control', as: :pages_control
  post ':restaurant_id/reload_i18n', to: 'translate#reload_i18n'
end
