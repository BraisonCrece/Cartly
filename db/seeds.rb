# frozen_string_literal: true

require 'faker'
require 'colorize'

################################################################################
# DATA
################################################################################

## MENU
# Dishes
starter_dish_image_map = {
  'Hummus con crudités' => 'hummus',
  'Bruschettas de tomate y albahaca' => 'tomate',
  'Rollitos de primavera' => 'rollito',
  'Guacamole con chips de plátano' => 'guacamole',
  'Paté de champiñones y nueces' => 'pate',
}

main_dishes_image_map = {
  'Curry de garbanzos y espinacas' => 'curry',
  'Lasaña de verduras' => 'lasaña',
  'Tacos de tempeh y aguacate' => 'tacos',
  'Bowl de quinoa con tofu y vegetales asados' => 'tofu',
  'Hamburguesa de lentejas con boniato' => 'hamburguesa',
}

desserts_image_map = {
  'Mousse de chocolate con aguacate' => 'mouse',
  'Tarta de manzana y canela' => 'manzana',
  'Helado de plátano y mantequilla de cacahuete' => 'helado',
  'Brownies de boniato y cacao' => 'brownie',
  'Cheesecake de anacardos y limón' => 'cheesecake',
}

starter_dishes_names = [
  'Hummus con crudités', 'Bruschettas de tomate y albahaca', 'Rollitos de primavera',
  'Guacamole con chips de plátano', 'Paté de champiñones y nueces',
]

main_dish_names = [
  'Curry de garbanzos y espinacas', 'Lasaña de verduras', 'Tacos de tempeh y aguacate',
  'Bowl de quinoa con tofu y vegetales asados', 'Hamburguesa de lentejas con boniato',
]

dessert_names = [
  'Mousse de chocolate con aguacate', 'Tarta de manzana y canela', 'Helado de plátano y mantequilla de cacahuete',
  'Brownies de boniato y cacao', 'Cheesecake de anacardos y limón',
]

starter_dishes_description = [
  'Crema de garbanzos con limón, tahini y ajo, acompañada de palitos de zanahoria, pepino y apio frescos.',
  'Rodajas de pan tostado con tomate fresco, ajo, aceite de oliva y hojas de albahaca, ideal para abrir el apetito.',
  'Envolturas de arroz rellenas de fideos, zanahoria, pepino y cilantro, servidos con salsa de cacahuete.',
  'Aguacate triturado con cebolla, cilantro, tomate y un toque de limón, acompañado de chips crujientes de plátano.',
  'Crema suave de champiñones y nueces, enriquecida con hierbas frescas, servida con pan tostado o crackers.',
]

main_dish_descriptions = [
  'Cremoso curry de garbanzos cocidos a fuego lento con espinacas frescas, servido sobre una cama de arroz basmati y
  acompañado de naan vegano.',
  'Capas de pasta de trigo intercaladas con calabacín, berenjena, espinacas y salsa de tomate, gratinadas con una
  cremosa bechamel de anacardos.',
  'Tortillas de maíz rellenas con tempeh marinado, trozos de aguacate, cebolla morada, cilantro fresco y una salsa
  casera de jalapeños.',
  'Quinoa esponjosa acompañada de tofu crujiente y una mezcla de vegetales asados, aderezada con una vinagreta de tahini
  y limón.',
  'Hamburguesa casera de lentejas y boniato en pan integral, con lechuga, tomate, cebolla caramelizada y
  mayonesa vegana.',
]

desserts_descriptions = [
  'Suave y cremosa mousse de chocolate hecha con aguacate, cacao en polvo y un toque de sirope de agave, servida con
  frutos rojos frescos.',
  'Masa integral rellena de rodajas de manzana caramelizadas con canela y azúcar de coco, horneada hasta quedar crujiente y
  dorada.',
  'Helado vegetariano elaborado a base de plátano congelado y mantequilla de cacahuete, cremoso y sin necesidad de lácteos
  ni azúcares añadidos.',
  'Brownies húmedos hechos con puré de boniato, cacao en polvo y harina de almendra, sin azúcar refinado y naturalmente
  dulces.',
  'Base de frutos secos y dátiles, cubierta con una crema suave de anacardos y limón, todo sin productos lácteos y con un
  sabor refrescante.',
]

## DAILY
# Starters
daily_starter_dishes_names = [
  'Crema de calabaza con jengibre', 'Ensalada de quinoa y espinacas', 'Hummus tricolor', 'Sopa miso con tofu y algas wakame', 'Verduras a la plancha con romesco casero'
]

daily_starter_dishes_descriptions = [
  'Crema suave de calabaza con un toque de jengibre fresco, aceite de coco y semillas de calabaza tostadas.',
  'Mezcla ligera de quinoa, espinacas frescas, granada, nueces y aguacate con un aliño de limón.',
  'Tres variedades de hummus: tradicional, remolacha y cúrcuma, servidos con bastones de zanahoria, pepino y pan pita.',
  'Sopa tradicional japonesa con tofu, algas, champiñones y fideos de arroz.',
  'Berenjena, calabacín, pimientos y espárragos con una deliciosa salsa romesco.'
]

daily_starter_dish_images_map = {
  'Crema de calabaza con jengibre' => 'calabaza',
  'Ensalada de quinoa y espinacas' => 'quinoa_esp',
  'Hummus tricolor' => 'hummus_tri',
  'Sopa miso con tofu y algas wakame' => 'miso',
  'Verduras a la plancha con romesco casero' => 'verduras'
}

# Main dishes
daily_main_dish_names = [
  'Albóndigas de lentejas en salsa de tomate', 'Curry de garbanzos y coco', 'Hamburguesa de remolacha y avena', 'Tacos de jackfruit estilo "pulled pork"', 'Lasaña de berenjena con espinacas y tofu ricotta'
]

daily_main_dish_descriptions = [
  'Albóndigas vegetales hechas con lentejas, servidas con arroz basmati y un toque de perejil.',
  'Plato cremoso de curry con coliflor, espinacas frescas y leche de coco, acompañado de arroz blanco.',
  'Hamburguesa vegetal acompañada de boniatos al horno y alioli vegano.',
  'Tacos rellenos de jackfruit deshilachado, pico de gallo, guacamole y salsa chipotle.',
  'Capas de berenjena con espinacas y ricotta de tofu, cubiertas con bechamel vegana dorada al horno.'
]

daily_main_dish_images_map = {
  'Albóndigas de lentejas en salsa de tomate' => 'albondigas',
  'Curry de garbanzos y coco' => 'curry_coco',
  'Hamburguesa de remolacha y avena' => 'burguer_remo',
  'Tacos de jackfruit estilo "pulled pork"' => 'tacos',
  'Lasaña de berenjena con espinacas y tofu ricotta' => 'lasana_day'
}

# Desserts
daily_dessert_names = [
  'Brownie vegano de chocolate y nueces', 'Tarta de queso vegana con frutos rojos', 'Pudding de chía con leche de coco y mango'
]

daily_dessert_descriptions = [
  'Brownie húmedo de chocolate con nueces, acompañado de helado vegano de vainilla.',
  'Base de dátiles y almendras con crema de queso vegana, cubierta de frambuesas y fresas frescas.',
  'Pudding de chía con leche de coco, cubierto de trozos de mango fresco y coco rallado.'
]

daily_dessert_images_map = {
  'Brownie vegano de chocolate y nueces' => 'brownie_nueces',
  'Tarta de queso vegana con frutos rojos' => 'tarta_frutos',
  'Pudding de chía con leche de coco y mango' => 'chia_pudding'
}

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
  'Albamar' => 'Vino blanco de la D.O. Rías Baixas, elaborado con Albariño. Fresco y vibrante, con aromas a frutas cítricas y un toque mineral. Perfecto para mariscos y pescados.',
  'A Pedreira' => 'Vino blanco de la D.O. Rías Baixas, hecho con Albariño. De gran frescura y complejidad, con aromas a frutas blancas y notas herbáceas. En el paladar es suave, equilibrado y con buena acidez. Ideal para acompañar platos de mariscos y pescados.',
  'Leirana' => 'Vino blanco de la D.O. Rías Baixas, elaborado con Albariño. De aromáticas intensas a frutas de carne y cítricos, con un toque mineral. En el gusto es fresco, untuoso y con una acidez bien equilibrada. Perfecto para mariscos, pescados y arroces.',
  'Eduardo Bravo' => 'Vino blanco de la D.O. Rías Baixas, elaborado con Albariño. Presenta aromas a frutas tropicales, cítricos y un toque floral. En el paladar es amplio, fresco y de buena acidez, con un final elegante. Ideal para acompañar mariscos, pescado fresco y platos de arroz.',
  'El Patito Feo' => 'Vino blanco de la D.O. Ribeiro, elaborado con variedades autóctonas. Destaca por sus aromas frescos a frutas blancas y notas florales. En el paladar es suave, ligero y con una acidez bien integrada. Perfecto para acompañar platos vegetales, ensaladas y quesos veganos.',
  'Mein' => 'Vino blanco de la D.O. Ribeiro, hecho con treixadura y otras variedades locales. Ofrece aromas frescos y florales, con notas de frutas blancas y un toque de hierba fresca. En el paladar es equilibrado, suave y con una acidez agradable. Perfecto para platos vegetales, arroces y ensaladas frescas.',
  'Gaba do Xil "O Barreiro"' => 'Vino blanco de la D.O. Valdeorras, elaborado con Godello. Tiene un aroma complejo a frutas blancas, cítricos y notas minerales. En el paladar es fresco, estructurado y con una acidez equilibrada. Ideal para acompañar platos vegetales, arroces y quesos veganos.',
  'Louro' => 'Vino blanco de la D.O. Rías Baixas, elaborado con Albariño y otras variedades autóctonas. Presenta aromas frescos y afrutados, con notas de cítricos y hierba. En el paladar es ligero, fresco y con acidez equilibrada. Perfecto para acompañar platos vegetales, pasta, risottos y tapas veganas.',
}

red_denominations_wines_descriptions_map = {
  'Carlos Serres' => 'Elaborado principalmente con Tempranillo, complementado con Graciano y Mazuelo. Presenta un color rojo rubí intenso y aromas complejos que combinan frutas negras maduras, especias y notas de vainilla derivadas de la crianza en barrica. En el paladar es equilibrado, con una acidez refrescante, taninos suaves y un final persistente.',
  'Bienlarme' => 'Elaborado principalmente con mencía. Tiene un color rojo intenso y una nariz compleja, con aromas a frutas negras, especias y leves toques herbáceos. En el paladar es de cuerpo medio, con una acidez equilibrada y taninos suaves, que le proporcionan un final ligeramente afrutado y persistente.',
  'La Montesa' => 'Elaborado principalmente con Garnacha, complementada con otras variedades autóctonas. Presenta un color rojo rubí brillante y aromas a frutas rojas maduras, con notas florales y especiadas. En el paladar es fresco, de cuerpo medio, con una acidez equilibrada y taninos suaves, que le confieren un final largo y sedoso.',
  'Canto do Cuco' => 'Vino tinto de la D.O. Ribeiro, hecho con mencía y otras variedades autóctonas. De color rojo intenso, con aromas a frutas negras y especias. En el paladar es fresco, de cuerpo medio y taninos suaves, con un final afrutado y equilibrado.',
  'El Patito Feo' => 'Vino tinto de la D.O. Ribeiro, elaborado con mencía. Presenta aromas a frutas rojas maduras, con toques especiados y herbáceos. En el paladar es suave, de cuerpo medio, con una acidez equilibrada y taninos bien integrados.',
  'Promine Singular' => 'Elaborado con mencía y otras variedades autóctonas. Tiene un color rojo intenso y aromas a frutas negras, especias y leves notas de madera. En el paladar es de cuerpo medio, con una acidez fresca y taninos suaves, que le dan un final largo y equilibrado.',
  'Saiñas Silente' => 'Vino tinto de la D.O. Ribeira Sacra, elaborado con uvas de mencía cultivadas en viñedos de más de 30 años de antigüedad. Presenta un color rojo intenso con matices violáceos y aromas a frutas rojas maduras, con notas especiadas y minerales. ',
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

restaurant_logo_image_path = Rails.root.join('app', 'assets', 'images', 'seeds', 'restaurant_logo.png')

Mobility.with_locale(:es) do
  restaurant = Restaurant.create!(
    email: 'test@test.com',
    password: 'Abc123..',
    name: 'Taberna Navegación',
    address: 'Travesía da Igrexa, 6',
    city: 'A Estrada',
    province: 'Pontevedra',
    phone: '654321098'
  )

  if File.exist?(restaurant_logo_image_path)
    restaurant.logo.attach(
      io: File.open(restaurant_logo_image_path),
      filename: 'restaurant_logo.png',
      content_type: 'image/png'
    )
  else
    print_info('Warning: Restaurant logo not found')
  end

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
    Category.create!(name: name, category_type: 'menu', restaurant: restaurant)
    print_info("Created menu category: #{name}")
  end

  daily_categories.each do |name|
    Category.create!(name: name, category_type: 'daily', restaurant: restaurant)
    print_info("Created daily category: #{name}")
  end

  print_header('Creating Dishes')

  create_dishes(starter_dishes_names, starter_dishes_description, starter_dish_image_map, '🥗 Entrantes 🥗', restaurant)
  create_dishes(main_dish_names, main_dish_descriptions, main_dishes_image_map, '🍽️ Platos 🍽️', restaurant)
  create_dishes(dessert_names, desserts_descriptions, desserts_image_map, '🍰 Postres 🍰', restaurant)

  create_dishes(daily_starter_dishes_names, daily_starter_dishes_descriptions, daily_starter_dish_images_map, 'Primeiros', restaurant)
  create_dishes(daily_main_dish_names, daily_main_dish_descriptions, daily_main_dish_images_map, 'Segundos', restaurant)
  create_dishes(daily_dessert_names, daily_dessert_descriptions, daily_dessert_images_map, 'Postres', restaurant)

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
end
print_header('Seeding Completed 🚀')
