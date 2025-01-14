# frozen_string_literal: true

FactoryBot.define do
  factory :drink do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
    price { Faker::Number.decimal(l_digits: 2) }
  end
end
