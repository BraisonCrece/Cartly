# frozen_string_literal: true

# Routes for the application
# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  root 'landing#index'

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  unless defined?(::Rake::SprocketsTask)
    devise_for :restaurants,
      path: 'admin',
      path_names: { sign_in: 'acceso', sign_out: 'sign_out', sign_up: 'registro' },
      controllers: {
        sessions: 'restaurants/sessions',
        registrations: 'restaurants/registrations',
        confirmations: 'restaurants/confirmations',
      }
  end


  # User-facing routes
  get ':restaurant_id/menu', to: 'menu#daily_menu', as: :menu
  get ':restaurant_id/carta', to: 'menu#menu', as: :carta
  get ':restaurant_id/qr', to: 'dynamic_router#call', as: :qr
  post ':restaurant_id/reload_i18n', to: 'translate#reload_i18n'

  # Model CRUDs
  resources :settings, only: :update
  resources :allergens, path: 'admin/alergenos'
  resources :dishes, path: 'admin/platos', path_names: {
    new: 'nuevo',
    edit: 'editar'
  }
  resources :drinks, path: 'admin/bebidas'
  resources :wines, path: 'admin/vinos'

  # Control Panel
  get '/admin/productos', to: 'control_panel#products', as: :control_panel_products
  get '/admin/settings', to: 'settings#edit', as: :admin_settings
  get '/admin/perfil', to: 'restaurants/profile#edit', as: :admin_profile
  patch '/admin/profile', to: 'restaurants/profile#update', as: :update_admin_profile
  resources :wine_origin_denominations, as: :admin_denominations, path: 'admin/denominaciones'
  resources :categories, as: :admin_categories, path: 'admin/categorias'
  resources :allergens, as: :admin_allergens, path: 'admin/alergenos'

  post 'toggle_active', to: 'control_panel#toggle_active', as: :toggle_active
  post 'toggle_special_menu/:special_menu_id', to: 'special_menus#toggle_active', as: :toggle_special_menu

  # Subscription management
  resource :subscription, only: [:show, :new, :create], path: 'admin/subscription' do
    member do
      get :success
      get :cancel
      patch :cancel_subscription
      patch :reactivate
      get :billing_portal
    end
  end

  # Profile

  # Other actions routes
  post 'translate', to: 'translate#translate'
  post 'describe_dish', to: 'description#describe_dish'

  # geenrate_qr_code
  namespace :private do
    post 'generate_qr_code', to: 'qr_code#generate', as: :generate_qr_code
  end

  post '/reload_i18n', to: 'translate#reload_i18n'
  post 'sort', to: 'categories#reorder'
  post 'stripe/webhook', to: 'webhooks/stripe#webhook'
end
# rubocop:enable Metrics/BlockLength
