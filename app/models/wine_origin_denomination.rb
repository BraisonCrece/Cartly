class WineOriginDenomination < ApplicationRecord
  belongs_to :restaurant
  has_many :wines
end

