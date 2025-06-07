# frozen_string_literal: true

class Restaurant < ApplicationRecord
  has_one_attached :logo, dependent: :destroy
  has_one_attached :logo_white, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :email, presence: { message: 'É obrigatorio o uso dun email' }
  validates :email, uniqueness: { message: 'O email xa existe na base de datos', case_sensitive: false }
  validates :name, presence: true, length: { maximum: 255 }

  has_many :dishes, dependent: :destroy
  has_many :drinks, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :allergens, dependent: :destroy
  has_many :special_menus, dependent: :destroy
  has_many :wines, dependent: :destroy
  has_many :wine_origin_denominations, dependent: :destroy
  has_one :setting, dependent: :destroy

  def full_address
    "#{address}, #{city}, #{province}"
  end

  def google_maps_link
    base_url = 'https://www.google.com/maps/search/?api=1'
    query = "#{name}, #{full_address}"
    "#{base_url}&query=#{CGI.escape(query)}"
  end

  # Image procesing before attach, allowed formats [:jpg, :png, :webp]
  def process_image(file:, attachment_name:, saver: 60)
    ImageProcessingService.new(file:, record: self, saver: saver, attachment_name: attachment_name, background_fill: false).call
  end

  def subscription_active?
    subscription_status == 'active' && subscription_current_period_end&.future?
  end

  def subscription_expired?
    subscription_current_period_end&.past?
  end

  def subscription_inactive?
    subscription_status == 'inactive' || subscription_status.nil?
  end

  def subscription_trialing?
    subscription_status == 'trialing'
  end

  def subscription_past_due?
    subscription_status == 'past_due'
  end

  def subscription_canceled?
    subscription_status == 'canceled'
  end

  def has_valid_subscription?
    subscription_active? || subscription_trialing?
  end

  def create_stripe_customer
    return stripe_customer_id if stripe_customer_id.present?

    customer = Stripe::Customer.create(
      email: email,
      name: name,
      metadata: { restaurant_id: id }
    )

    update!(stripe_customer_id: customer.id)
    customer.id
  end

  def update_subscription_status(status, current_period_end = nil)
    update!(
      subscription_status: status,
      subscription_current_period_end: current_period_end
    )
  end
end
