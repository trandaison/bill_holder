class Apartment < ApplicationRecord
  has_many :meters, dependent: :destroy
end
