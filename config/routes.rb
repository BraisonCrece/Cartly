# frozen_string_literal: true

# Routes for the application
# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  root 'landing#index'

  # Auth
  unless defined?(Rake::SprocketsTask)
    devise_for :restaurants,
               path: 'admin',
               path_names: { sign_in: 'sign_in', sign_out: 'sign_out', sign_up: 'sign_up' },
               controllers: {
                 sessions: 'restaurants/sessions',
                 registrations: 'restaurants/registrations',
               }
  end

  # Model CRUDs
  resources :allergens
  resources :categories
  resources :dishes
  resources :special_menus
  resources :wines
  resources :wine_types
  resources :wine_origin_denominations, as: :denominations, path: 'denominations'

  # User-facing routes
  get ':restaurant_id/menu', to: 'public/products#daily', as: :menu
  # get ':restaurant_id/menu', to: 'dishes#menu', as: :menu
  get ':restaurant_id/carta', to: 'public/products#menu', as: :carta
  # get ':restaurant_id/carta', to: 'dishes#index', as: :carta
  get ':restaurant_id/qr', to: 'dynamic_router#call', as: :qr
  post ':restaurant_id/reload_i18n', to: 'translate#reload_i18n'

  # Control Panel
  get '/control_panel/dishes', to: 'control_panel#dishes', as: :dishes_control_panel
  get '/control_panel/wines', to: 'control_panel#wines', as: :wines_control_panel
  post 'toggle_active', to: 'control_panel#toggle_active', as: :toggle_active
  post 'toggle_special_menu/:special_menu_id', to: 'special_menus#toggle_active', as: :toggle_special_menu

  # Special menu dishes
  resources :special_menu do
    resources :dishes, controller: 'special_menus/dishes', only: [:new, :create, :edit, :update, :destroy]
  end

  # Settings
  get 'settings', to: 'settings#edit'
  resources :settings, only: :update

  # Profile
  get 'profile', to: 'restaurants/profile#edit'
  patch 'profile', to: 'restaurants/profile#update'

  # Other actions routes
  post 'translate', to: 'translate#translate'
  post 'describe_dish', to: 'description#describe_dish'

  # geenrate_qr_code
  namespace :private do
    post 'generate_qr_code', to: 'qr_code#generate', as: :generate_qr_code
  end

  post '/reload_i18n', to: 'translate#reload_i18n'
  post 'sort', to: 'categories#reorder'
end
# rubocop:enable Metrics/BlockLength
