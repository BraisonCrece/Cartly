# frozen_string_literal: true

require 'faker'
require 'colorize'

# Helper methods
def print_header(message)
  puts "\n#{'=' * 50}".yellow
  puts message.center(50).yellow.bold
  puts ('=' * 50).yellow
end

def print_info(message)
  puts "  #{message}".cyan
end

def open_image_file(path)
  if File.exist?(path)
    ActionDispatch::Http::UploadedFile.new(
      tempfile: File.open(path),
      filename: 'placeholder.webp',
      type: 'image/webp'
    )
  else
    print_info("  Warning: placeholder.webp not found at #{path}")
  end
end

# Allergen methods
def create_allergens(allergens)
  allergens.each do |name|
    allergen = create_allergen(name)
    attach_allergen_icon(allergen)
    save_allergen(allergen)
  end
end

def create_allergen(name)
  Allergen.new(name:)
end

def attach_allergen_icon(allergen)
  allergen_image_path = Rails.root.join('app', 'assets', 'images', 'allergens', "#{allergen.name.downcase}.png")

  if File.exist?(allergen_image_path)
    allergen.icon.attach(
      io: File.open(allergen_image_path),
      filename: "#{allergen.name.downcase}.png",
      content_type: 'image/png'
    )
  else
    print_info("  Warning: Allergen image not found for #{allergen.name}")
  end
end

def save_allergen(allergen)
  if allergen.save
    print_info("Created allergen: #{allergen.name}")
  else
    print_info("Failed to create allergen: #{allergen.name}")
    print_info("Errors: #{allergen.errors.full_messages.join(', ')}")
  end
end

# Product methods
def create_products_for_category(category, image_file, number_of_products: 10)
  number_of_products.times do
    product = create_product_for_category(category)
    add_random_allergens_to_product(product)
    product.process_image(image_file)
    save_product(product)
  end
end

def generate_product_name(category)
  case category.name
  when '🥗 Entrantes 🥗', 'Primeiros'
    Faker::Food.dish
  when '🍽️ Platos 🍽️', 'Segundos'
    "#{Faker::Food.ingredient} with #{Faker::Food.vegetables}"
  when 'Postres', '🍰 Postres 🍰'
    Faker::Dessert.variety
  end
end

def create_product_for_category(category)
  product_name = generate_product_name(category)

  Product.new(
    title: product_name,
    description: Faker::Food.description,
    active: true,
    prize: rand(5.0..25.0).round(2),
    category:
  )
end

def add_random_allergens_to_product(product)
  allergens = Allergen.all.sample(rand(0..6))
  product.allergens << allergens
  print_info("  Added #{allergens.count} allergens to #{product.title}")
end

def save_product(product)
  if product.save
    print_info("  Created product: #{product.title}")
  else
    print_info("  Failed to create product: #{product.title}")
    print_info("  Errors: #{product.errors.full_messages.join(', ')}")
  end
end

# Wine methods
def create_wines_for_denomination(denomination, wine_types)
  print_info("Creating wines for denomination: #{denomination}")
  5.times do
    wine = create_wine_for_denomination(denomination, wine_types)
    attach_wine_image(wine)
    save_wine(wine)
  end
end

def create_wine_for_denomination(denomination, wine_types)
  Wine.new(
    name: generate_wine_name,
    wine_type: wine_types.sample,
    description: generate_wine_description(denomination),
    price: rand(10.0..50.0).round(2),
    wine_origin_denomination: WineOriginDenomination.find_by(name: denomination),
    active: true
  )
end

def generate_wine_name
  "#{Faker::Name.last_name} #{Faker::Ancient.god} #{Faker::Color.color_name.capitalize}"
end

def generate_wine_description(denomination)
  if ['Rías Baixas', 'Rueda', 'Albariño', 'Ribeiro', 'Valdeorras'].include?(denomination)
    "A delightful white wine from #{denomination} with notes of #{Faker::Food.fruits} and #{Faker::Food.spice}"
  else
    "A robust red wine from #{denomination} with hints of #{Faker::Food.fruits} and #{Faker::Food.ingredient}"
  end
end

def attach_wine_image(wine)
  placeholder_path = Rails.root.join('app', 'assets', 'images', 'wine-placeholder.webp')
  if File.exist?(placeholder_path)
    wine.image.attach(io: File.open(placeholder_path), filename: 'wine-placeholder.webp', content_type: 'image/webp')
  else
    print_info("  Warning: wine-placeholder.webp not found at #{placeholder_path}")
  end
end

def save_wine(wine)
  if wine.save
    print_info("  Created wine: #{wine.name}")
  else
    print_info("  Failed to create wine: #{wine.name}")
    print_info("  Errors: #{wine.errors.full_messages.join(', ')}")
  end
end

# Seed execution
print_header('Seeding Database')
# Create test user
print_header('Creating Test User')
user = User.create!(
  email: 'test@test.com',
  password: 'Abc123..'
)
if user.persisted?
  print_info("Created test user: #{user.email}")
else
  print_info('Failed to create test user')
  print_info("Errors: #{user.errors.full_messages.join(', ')}")
end

# Allergens
print_header('Creating Allergens')
allergens = %w[gluten huevo leche pescado marisco soia cacahuete apio mostaza
               sesamo sulfitos altramuces almendra azucar maiz mel picante setas]
create_allergens(allergens)

# Categories
print_header('Creating Categories')
menu_categories = ['🥗 Entrantes 🥗', '🍽️ Platos 🍽️', '🍰 Postres 🍰']
daily_categories = %w[Primeiros Segundos Postres]

menu_categories.each do |name|
  Category.create!(name:, category_type: 'menu')
  print_info("Created menu category: #{name}")
end

daily_categories.each do |name|
  Category.create!(name:, category_type: 'daily')
  print_info("Created daily category: #{name}")
end

# Products
print_header('Creating Products')
all_categories = Category.all

placeholder_path = Rails.root.join('app', 'assets', 'images', 'placeholder.webp')
product_image_file = open_image_file(placeholder_path)

all_categories.each do |category|
  print_info("Creating products for category: #{category.name}")
  create_products_for_category(category, product_image_file, number_of_products: 10)
end

# Wine Origin Denominations
print_header('Creating Wine Origin Denominations')
white_denominations = ['Rías Baixas', 'Rueda', 'Albariño', 'Ribeiro', 'Valdeorras']
red_denominations = ['Rioja', 'Ribera del Duero', 'Priorat', 'Bierzo', 'Toro']

(white_denominations + red_denominations).each do |name|
  WineOriginDenomination.create!(name:)
  print_info("Created denomination: #{name}")
end

# Wines
print_header('Creating Wines')
white_types = ['Blanco']
red_types = ['Tinto']

white_denominations.each do |denomination|
  create_wines_for_denomination(denomination, white_types)
end

red_denominations.each do |denomination|
  create_wines_for_denomination(denomination, red_types)
end

print_header('Seeding Completed 🚀')
