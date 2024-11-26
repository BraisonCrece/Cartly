# frozen_string_literal: true

require 'faker'
require 'colorize'

################################################################################
# DATA
################################################################################

# Dishes
starter_dish_image_map = {
  'Hummus con crudités' => 'hummus',
  'Bruschettas de tomate e alfábega' => 'tomate',
  'Roliños de primaveira' => 'rollito',
  'Guacamole con chips de plátano' => 'guacamole',
  'Paté de cogomelos e noces' => 'pate',
}

main_dishes_image_map = {
  'Curry de garavanzos e espinacas' => 'curry',
  'Lasaña de verduras' => 'lasaña',
  'Tacos de tempeh e aguacate' => 'tacos',
  'Bowl de quinoa con tofu e vexetais asados' => 'tofu',
  'Hamburguesa de lentellas con batata' => 'hamburguesa',
}

desserts_image_map = {
  'Mousse de chocolate con aguacate' => 'mouse',
  'Tarta de mazá e canela' => 'manzana',
  'Xeado de plátano e manteiga de cacahuete' => 'helado',
  'Brownies de batata doce e cacao' => 'brownie',
  'Cheesecake de anacardos e limón' => 'cheesecake',
}

starter_dishes_names = [
  'Hummus con crudités', 'Bruschettas de tomate e alfábega', 'Roliños de primaveira',
  'Guacamole con chips de plátano', 'Paté de cogomelos e noces',
]

main_dish_names = [
  'Curry de garavanzos e espinacas', 'Lasaña de verduras', 'Tacos de tempeh e aguacate',
  'Bowl de quinoa con tofu e vexetais asados', 'Hamburguesa de lentellas con batata',
]

dessert_names = [
  'Mousse de chocolate con aguacate', 'Tarta de mazá e canela', 'Xeado de plátano e manteiga de cacahuete',
  'Brownies de batata doce e cacao', 'Cheesecake de anacardos e limón',
]

starter_dishes_description = [
  'Crema de garavanzos con limón, tahini e allo, acompañada de paíños de cenoria, pepino e apio frescos.',
  'Rodelas de pan torrado con tomate fresco, allo, aceite de oliva e follas de alfábega, ideal para abrir o apetito.',
  'Envolturas de arroz recheas de fideos, cenoria, pepino e coandro, servidos con salsa de cacahuete.',
  'Aguacate triturado con cebola, coandro, tomate e un toque de limón, acompañado de chips crocantes de plátano.',
  'Crema suave de cogomelos e noces, enriquecida con herbas frescas, servida con pan torrado ou crackers.',
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
  maionesa vegana.',
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
  sabor refrescante.',
]

# Wines
white_denominations_wines_names_map = {
  'Rías Baixas' => ['Albamar', 'A Pedreira', 'Leirana'],
  'Ribeiro' => ['Eduardo Bravo', 'El Patito Feo', 'Mein'],
  'Valdeorras' => ['Gaba do Xil "O Barreiro"', 'Louro'],
}

red_denominations_wines_names_map = {
  'Rioja' => ['Carlos Serres', 'Bienlarme', 'La Montesa'],
  'Ribeiro' => ['Canto do Cuco', 'El Patito Feo'],
  'Ribeira Sacra' => ['Promine Singular', 'Saiñas Silente'],
}

white_denominations_wines_descriptions_map = {
  'Albamar' => 'Viño branco da D.O. Rías Baixas, elaborado con Albariño. Fresco e vibrante, con aromas a froitas cítricas e un toque mineral. Perfecto para mariscos e peixes.',
  'A Pedreira' => 'Viño branco da D.O. Rías Baixas, feito con Albariño. De gran frescura e complexidade, con aromas a froitas brancas e notas herbáceas. No paladar é suave, equilibrado e con boa acidez. Ideal para acompañar pratos de mariscos e peixes.',
  'Leirana' => 'Viño branco da D.O. Rías Baixas, elaborado con Albariño. De aromáticas intensas a froitas de carme e cítricos, cun toque mineral. No gusto é fresco, untuoso e cunha acidez ben equilibrada. Perfecto para mariscos, pescados e arroces.',
  'Eduardo Bravo' => 'Viño branco da D.O. Rías Baixas, elaborado con Albariño. Presenta aromas a froitas tropicais, cítricos e un toque floral. No paladar é amplo, fresco e de boa acidez, cun final elegante. Ideal para acompañar mariscos, peixe fresco e pratos de arroz.',
  'El Patito Feo' => 'Viño branco da D.O. Ribeiro, elaborado con variedades autóctonas. Destaca por os seus aromas frescos a froitas brancas e notas florais. No paladar é suave, lixeiro e cunha acidez ben integrada. Perfecto para acompañar pratos vexetais, ensaladas e queixos veganos.',
  'Mein' => 'Viño branco da D.O. Ribeiro, feito con treixadura e outras variedades locais. Ofrece aromas frescos e florais, con notas de froitas brancas e un toque de herba fresca. No paladar é equilibrado, suave e con unha acidez agradable. Perfecto para pratos vexetais, arroces e ensaladas frescas.',
  'Gaba do Xil "O Barreiro"' => 'Viño branco da D.O. Valdeorras, elaborado con Godello. Ten unha aroma complexa a froitas brancas, cítricos e notas minerais. No paladar é fresco, estruturado e con unha acidez equilibrada. Ideal para acompañar pratos vexetais, arroces e queixos veganos.',
  'Louro' => 'Viño branco da D.O. Rías Baixas, elaborado con Albariño e outras variedades autóctonas. Presenta aromas frescos e afroitados, con notas de cítricos e herba. No paladar é lixeiro, fresco e con acidez equilibrada. Perfecto para acompañar pratos vexetais, pasta, risottos e tapas veganas.',
}

red_denominations_wines_descriptions_map = {
  'Carlos Serres' => 'Elaborado principalmente con Tempranillo, complementado con Graciano e Mazuelo. Presenta unha cor vermella rubí intensa e aromas complexos que combinan froitas negras maduras, especias e notas de vainilla derivadas da crianza en barrica. No paladar é equilibrado, cunha acidez refrescante, taninos suaves e un final persistente.',
  'Bienlarme' => 'Elaborado principalmente con mencía. Ten unha cor vermella intensa e unha nariz complexa, con aromas a froitas negras, especias e leves toques herbáceos. No paladar é de corpo medio, cunha acidez equilibrada e taninos suaves, que lle proporcionan un final lixeiramente afroitado e persistente.',
  'La Montesa' => 'Elaborado principalmente con Garnacha, complementada con outras variedades autóctonas. Presenta unha cor vermella rubí brillante e aromas a froitas vermellas maduras, con notas florais e especiadas. No paladar é fresco, de corpo medio, cunha acidez equilibrada e taninos suaves, que lle confiren un final longo e sedoso.',
  'Canto do Cuco' => 'Viño tinto da D.O. Ribeiro, feito con mencía e outras variedades autóctonas. De cor vermella intensa, con aromas a froitas negras e especias. No paladar é fresco, de corpo medio e taninos suaves, cun final afroitado e equilibrado.',
  'El Patito Feo' => 'Viño tinto da D.O. Ribeiro, elaborado con mencía. Presenta aromas a froitas vermellas maduras, con toques especiados e herbáceos. No paladar é suave, de corpo medio, cunha acidez equilibrada e taninos ben integrados.',
  'Promine Singular' => 'Elaborado con mencía e outras variedades autóctonas. Ten unha cor vermella intensa e aromas a froitas negras, especias e leves notas de madeira. No paladar é de corpo medio, cunha acidez fresca e taninos suaves, que lle dan un final longo e equilibrado.',
  'Saiñas Silente' => 'Viño tinto da D.O. Ribeira Sacra, elaborado con uvas de mencía cultivadas en viñedos de máis de 30 anos de antigüidade. Presenta unha cor vermella intensa con matices violáceos e aromas a froitas vermellas maduras, con notas especiadas e minerais. ',
}

white_wines_images_map = {
  'Albamar' => 'albamar.png',
  'A Pedreira' => 'pedreira.png',
  'Leirana' => 'leirana.png',
  'Eduardo Bravo' => 'bravo.jpg',
  'El Patito Feo' => 'patitofeo.jpg',
  'Mein' => 'mein.jpg',
  'Gaba do Xil "O Barreiro"' => 'xil.jpg',
  'Louro' => 'louro.jpg',
}

red_wines_images_map = {
  'Carlos Serres' => 'serres.jpg',
  'Bienlarme' => 'bienlarme.jpg',
  'La Montesa' => 'montesa.jpg',
  'Canto do Cuco' => 'cuco.jpg',
  'El Patito Feo' => 'patitofeo_tinto.jpg',
  'Promine Singular' => 'promine.jpg',
  'Saiñas Silente' => 'sainas.jpg',
}

################################################################################
# METHODS
################################################################################

def create_dishes(names, descriptions, images_map, category_name, restaurant)
  names.each_with_index do |name, index|
    path = Rails.root.join('app', 'assets', 'images', 'seeds', "#{images_map[name]}.webp")
    dish_image_file = open_image_file(path)
    dish = Dish.create!(
      title: name,
      description: descriptions[index],
      active: true,
      prize: rand(5.0..25.0).round(2),
      category: Category.find_by(name: category_name),
      restaurant:
    )
    add_random_allergens_to_dish(dish)
    dish.process_image(dish_image_file)
    save_dish(dish)
  end
end

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

def save_wine(wine)
  if wine.save
    print_info("  Created wine: #{wine.name}")
  else
    print_info("  Failed to create wine: #{wine.name}")
    print_info("  Errors: #{wine.errors.full_messages.join(', ')}")
  end
end

################################################################################
# EXECUTION
################################################################################

print_header('Seeding Database')
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

print_header('Creating Allergens')
allergens = ['gluten', 'huevo', 'leche', 'pescado', 'marisco', 'soia', 'cacahuete', 'apio', 'mostaza', 'sesamo', 'sulfitos', 'altramuces', 'almendra', 'azucar', 'maiz', 'mel', 'picante', 'setas']
create_allergens(allergens)

print_header('Creating Categories')
menu_categories = ['🥗 Entrantes 🥗', '🍽️ Platos 🍽️', '🍰 Postres 🍰']
daily_categories = ['Primeiros', 'Segundos', 'Postres']

menu_categories.each do |name|
  Category.create!(name: name, category_type: 'menu')
  print_info("Created menu category: #{name}")
end

daily_categories.each do |name|
  Category.create!(name: name, category_type: 'daily')
  print_info("Created daily category: #{name}")
end

print_header('Creating Dishes')

create_dishes(starter_dishes_names, starter_dishes_description, starter_dish_image_map, '🥗 Entrantes 🥗', restaurant)
create_dishes(main_dish_names, main_dish_descriptions, main_dishes_image_map, '🍽️ Platos 🍽️', restaurant)
create_dishes(dessert_names, desserts_descriptions, desserts_image_map, '🍰 Postres 🍰', restaurant)

create_dishes(starter_dishes_names, starter_dishes_description, starter_dish_image_map, 'Primeiros', restaurant)
create_dishes(main_dish_names, main_dish_descriptions, main_dishes_image_map, 'Segundos', restaurant)
create_dishes(dessert_names, desserts_descriptions, desserts_image_map, 'Postres', restaurant)

print_header('Creating Wines')

white_denominations_wines_names_map.each do |denomination, wines|
  origin = WineOriginDenomination.create!(name: denomination, restaurant:)
  print_info("Creating white wines for denomination: #{denomination}")
  wines.each do |wine_name|
    path = Rails.root.join('app', 'assets', 'images', 'seeds', 'wines', "#{white_wines_images_map[wine_name]}")
    wine_image_file = open_image_file(path)

    wine = Wine.create(
      restaurant:,
      name: wine_name,
      wine_type: 'Blanco',
      description: white_denominations_wines_descriptions_map[wine_name],
      price: rand(10.0..50.0).round(2),
      wine_origin_denomination: origin,
      active: true
    )
    wine.process_wine(wine_image_file)
  end
end

red_denominations_wines_names_map.each do |denomination, wines|
  origin = WineOriginDenomination.find_or_create_by(name: denomination, restaurant:)
  print_info("Creating white wines for denomination: #{denomination}")
  wines.each do |wine_name|
    path = Rails.root.join('app', 'assets', 'images', 'seeds', 'wines', "#{red_wines_images_map[wine_name]}")
    wine_image_file = open_image_file(path)
    wine = Wine.create(
      restaurant:,
      name: wine_name,
      wine_type: 'Tinto',
      description: red_denominations_wines_descriptions_map[wine_name],
      price: rand(10.0..50.0).round(2),
      wine_origin_denomination: origin,
      active: true
    )
    wine.process_wine(wine_image_file)
  end
end

print_header('Seeding Completed 🚀')
