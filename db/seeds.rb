# frozen_string_literal: true

require 'faker'
require 'colorize'

def create_dishes(names, descriptions, images_map, category_name, restaurant)
  names.each_with_index do |name, index|
    path = Rails.root.join('app', 'assets', 'images', 'seeds', "#{images_map[name]}.webp")
    dish_image_file = open_image_file(path)
    dish = Dish.create!(
      title: name,
      description: descriptions[index],
      active: true,
      prize: rand(5.0..25.0).round(2),
      category: Category.find_by(name: category_name, restaurant:),
      restaurant:
    )
    add_random_allergens_to_dish(dish)
    dish.process_image(dish_image_file)
    save_dish(dish)
  end
end

starter_dish_image_map = {
  'Hummus con crudités' => 'hummus',
  'Bruschettas de tomate e alfábega' => 'tomate',
  'Roliños de primaveira' => 'rollito',
  'Guacamole con chips de plátano' => 'guacamole',
  'Paté de cogomelos e noces' => 'pate'
}

main_dishes_image_map = {
  'Curry de garavanzos e espinacas' => 'curry',
  'Lasaña de verduras' => 'lasaña',
  'Tacos de tempeh e aguacate' => 'tacos',
  'Bowl de quinoa con tofu e vexetais asados' => 'tofu',
  'Hamburguesa de lentellas con batata' => 'hamburguesa'
}

desserts_image_map = {
  'Mousse de chocolate con aguacate' => 'mouse',
  'Tarta de mazá e canela' => 'manzana',
  'Xeado de plátano e manteiga de cacahuete' => 'helado',
  'Brownies de batata doce e cacao' => 'brownie',
  'Cheesecake de anacardos e limón' => 'cheesecake'
}

starter_dishes_names = [
  'Hummus con crudités', 'Bruschettas de tomate e alfábega', 'Roliños de primaveira',
  'Guacamole con chips de plátano', 'Paté de cogomelos e noces'
]

main_dish_names = [
  'Curry de garavanzos e espinacas', 'Lasaña de verduras', 'Tacos de tempeh e aguacate',
  'Bowl de quinoa con tofu e vexetais asados', 'Hamburguesa de lentellas con batata'
]

dessert_names = [
  'Mousse de chocolate con aguacate', 'Tarta de mazá e canela', 'Xeado de plátano e manteiga de cacahuete',
  'Brownies de batata doce e cacao', 'Cheesecake de anacardos e limón'
]

starter_dishes_description = [
  'Crema de garavanzos con limón, tahini e allo, acompañada de paíños de cenoria, pepino e apio frescos.',
  'Rodelas de pan torrado con tomate fresco, allo, aceite de oliva e follas de alfábega, ideal para abrir o apetito.',
  'Envolturas de arroz recheas de fideos, cenoria, pepino e coandro, servidos con salsa de cacahuete.',
  'Aguacate triturado con cebola, coandro, tomate e un toque de limón, acompañado de chips crocantes de plátano.',
  'Crema suave de cogomelos e noces, enriquecida con herbas frescas, servida con pan torrado ou crackers.'
]

main_dish_descriptions = [
  'Cremoso curry de garavanzos cocidos a lume lento con espinacas frescas, servido sobre unha cama de arroz basmati e
  acompañado de naan vegano.',
  'Capas de pasta de trigo intercaladas con cabaciña, berenxena, espinacas e salsa de tomate, gratinadas cunha
  cremosa bechamel de anacardos.',
  'Tortillas de millo recheas con tempeh mariñado, anacos de aguacate, cebola morada, coandro fresco e unha salsa
  caseira de xalapeños.',
  'Quinoa esponxosa acompañada de tofu crocante e unha mestura de vexetais asados, aderezada cunha vinagreta de tahini
  e limón.',
  'Hamburguesa caseira de lentellas e batata en pan integral, con leituga, tomate, cebola caramelizada e
  maionesa vegana.'
]

desserts_descriptions = [
  'Suave e cremosa mousse de chocolate feita con aguacate, cacao en po e un toque de xarope de agave, servida con
  froitos vermellos frescos.',
  'Masa integral rechea de rodelas de mazá caramelizadas con canela e azucre de coco, forneada ata quedar crocante e
  dourada.',
  'Xeado vexetariano elaborado a base de plátano conxelado e manteiga de cacahuete, cremoso e sen necesidade de lácteos
  nin azucres engadidos.',
  'Brownies húmidos feitos con puré de batata doce, cacao en po e fariña de améndoa, sen azucre refinado e naturalmente
  doces.',
  'Base de froitos secos e dátiles, cuberta cunha crema suave de anacardos e limón, todo sen produtos lácteos e cun
  sabor refrescante.'
]

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

def add_random_allergens_to_dish(dish)
  allergens = Allergen.all.sample(rand(0..6))
  dish.allergens << allergens
  print_info("  Added #{allergens.count} allergens to #{dish.title}")
end

def save_dish(dish)
  if dish.save
    print_info("  Created dish: #{dish.title}")
  else
    print_info("  Failed to create dish: #{dish.title}")
    print_info("  Errors: #{dish.errors.full_messages.join(', ')}")
  end
end

# Wine methods
def create_wines_for_denomination(denomination, wine_types, restaurant)
  print_info("Creating wines for denomination: #{denomination}")
  5.times do
    wine = create_wine_for_denomination(denomination, wine_types, restaurant)
    attach_wine_image(wine)
    save_wine(wine)
  end
end

def create_wine_for_denomination(denomination, wine_types, restaurant)
  Wine.new(
    restaurant:,
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
# Create test restaurant
print_header('Creating Test Restaurant')
restaurant = Restaurant.create!(
  email: 'test@test.com',
  password: 'Abc123..',
  name: 'Test Restaurant',
  address: '123 Test St, Test City, Test Country',
  phone: '+34 666 66 66 66'
)
if restaurant.persisted?
  print_info("Created test restaurant: #{restaurant.email}")
else
  print_info('Failed to create test restaurant')
  print_info("Errors: #{restaurant.errors.full_messages.join(', ')}")
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
  Category.create!(name: name, category_type: 'menu', restaurant:)
  print_info("Created menu category: #{name}")
end

daily_categories.each do |name|
  Category.create!(name: name, category_type: 'daily', restaurant:)
  print_info("Created daily category: #{name}")
end

# Dishes
print_header('Creating Dishes')

create_dishes(starter_dishes_names, starter_dishes_description, starter_dish_image_map, '🥗 Entrantes 🥗', restaurant)
create_dishes(main_dish_names, main_dish_descriptions, main_dishes_image_map, '🍽️ Platos 🍽️', restaurant)
create_dishes(dessert_names, desserts_descriptions, desserts_image_map, '🍰 Postres 🍰', restaurant)

create_dishes(starter_dishes_names, starter_dishes_description, starter_dish_image_map, 'Primeiros', restaurant)
create_dishes(main_dish_names, main_dish_descriptions, main_dishes_image_map, 'Segundos', restaurant)
create_dishes(dessert_names, desserts_descriptions, desserts_image_map, 'Postres', restaurant)

# Wine Origin Denominations
print_header('Creating Wine Origin Denominations')
white_denominations = ['Rías Baixas', 'Rueda', 'Albariño', 'Ribeiro', 'Valdeorras']
red_denominations = ['Rioja', 'Ribera del Duero', 'Priorat', 'Bierzo', 'Toro']

(white_denominations + red_denominations).each do |name|
  WineOriginDenomination.create!(name:, restaurant:)
  print_info("Created denomination: #{name}")
end

# Wines
print_header('Creating Wines')
white_types = ['Blanco']
red_types = ['Tinto']

white_denominations.each do |denomination|
  create_wines_for_denomination(denomination, white_types, restaurant)
end

red_denominations.each do |denomination|
  create_wines_for_denomination(denomination, red_types, restaurant)
end

print_header('Seeding Completed 🚀')
