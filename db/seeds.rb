# frozen_string_literal: true

require 'faker'
require 'colorize'

def print_header(message)
  puts "\n#{'=' * 50}".yellow
  puts message.center(50).yellow.bold
  puts ('=' * 50).yellow
end

def print_info(message)
  puts "  #{message}".cyan
end

print_header('Seeding Database')

# Allergens
print_header('Creating Allergens')
allergens = %w[gluten huevo leche pescado marisco soia cacahuete apio mostaza
               sesamo sulfitos altramuces almendra azucar maiz mel picante setas]

allergens.each do |name|
  allergen = Allergen.new(name:)
  allergen.icon.attach(
    io: File.open(Rails.root.join('app', 'assets', 'images', 'allergens',
                                  "#{allergen.name.downcase}.png")),
    filename: "#{allergen.name.downcase}.png",
    content_type: 'image/png'
  )
  allergen.save!
  print_info("Created allergen: #{name}")
end

# Categories
print_header('Creating Categories')
menu_categories = %w[Entrantes Platos Postres]
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

all_categories.each do |category|
  print_info("Creating products for category: #{category.name}")
  10.times do
    product_name = case category.name
                   when 'Entrantes', 'Primeiros'
                     Faker::Food.dish
                   when 'Platos', 'Segundos'
                     "#{Faker::Food.ingredient} with #{Faker::Food.vegetables}"
                   when 'Postres'
                     Faker::Dessert.variety
                   end

    product = Product.new(
      title: product_name,
      description: Faker::Food.description,
      active: true,
      prize: rand(5.0..25.0).round(2),
      category:
    )

    # Add random allergens to the product (maximum 6)
    allergens = Allergen.all.sample(rand(0..6))
    product.allergens << allergens
    print_info("  Added #{allergens.count} allergens to #{product_name}")

    # Attach the placeholder image
    placeholder_path = Rails.root.join('app', 'assets', 'images', 'placeholder.jpg')
    if File.exist?(placeholder_path)
      product.picture.attach(io: File.open(placeholder_path), filename: 'placeholder.jpg', content_type: 'image/jpeg')
    else
      print_info("  Warning: placeholder.jpg not found at #{placeholder_path}")
    end

    if product.save
      print_info("  Created product: #{product_name}")
    else
      print_info("  Failed to create product: #{product_name}")
      print_info("  Errors: #{product.errors.full_messages.join(', ')}")
    end
  end
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
  print_info("Creating white wines for denomination: #{denomination}")
  5.times do
    wine = Wine.new(
      name: "#{Faker::Name.last_name} #{Faker::Ancient.god} #{Faker::Color.color_name.capitalize}",
      wine_type: white_types.sample,
      description: "A delightful white wine from #{denomination} with notes of #{Faker::Food.fruits} and #{Faker::Food.spice}",
      price: rand(10.0..50.0).round(2),
      wine_origin_denomination: WineOriginDenomination.find_by(name: denomination),
      active: true
    )

    # Attach the placeholder image
    placeholder_path = Rails.root.join('app', 'assets', 'images', 'wine-placeholder.webp')
    if File.exist?(placeholder_path)
      wine.image.attach(io: File.open(placeholder_path), filename: 'wine-placeholder.webp', content_type: 'image/webp')
    else
      print_info("  Warning: wine-placeholder.webp not found at #{placeholder_path}")
    end

    if wine.save
      print_info("  Created white wine: #{wine.name}")
    else
      print_info("  Failed to create white wine: #{wine.name}")
      print_info("  Errors: #{wine.errors.full_messages.join(', ')}")
    end
  end
end

red_denominations.each do |denomination|
  print_info("Creating red wines for denomination: #{denomination}")
  5.times do
    wine = Wine.new(
      name: "#{Faker::Name.last_name} #{Faker::Ancient.primordial} #{Faker::Color.color_name.capitalize}",
      wine_type: red_types.sample,
      description: "A robust red wine from #{denomination} with hints of #{Faker::Food.fruits} and #{Faker::Food.ingredient}",
      price: rand(10.0..50.0).round(2),
      wine_origin_denomination: WineOriginDenomination.find_by(name: denomination),
      active: true
    )

    # Attach the placeholder image
    placeholder_path = Rails.root.join('app', 'assets', 'images', 'wine-placeholder.webp')
    if File.exist?(placeholder_path)
      wine.image.attach(io: File.open(placeholder_path), filename: 'wine-placeholder.webp', content_type: 'image/webp')
    else
      print_info("  Warning: wine-placeholder.webp not found at #{placeholder_path}")
    end

    if wine.save
      print_info("  Created red wine: #{wine.name}")
    else
      print_info("  Failed to create red wine: #{wine.name}")
      print_info("  Errors: #{wine.errors.full_messages.join(', ')}")
    end
  end
end

print_header('Seeding Completed')
