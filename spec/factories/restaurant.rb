FactoryBot.define do
  factory :restaurant do
    email { Faker::Internet.email }
    password { "Abc123.." }
    name { Faker::Restaurant.name }
    address { Faker::Address.full_address }
    phone { Faker::PhoneNumber.cell_phone }
    description { Faker::Lorem.paragraph }
    password_confirmation { "Abc123.." }
  end
end
