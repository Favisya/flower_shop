class Bouquet < ApplicationRecord
  validates :number,numericality: true
  # validates :number,length: {minimum: 11, maximum: 12}
  #has_and_belongs_to_many :flowers
  has_many :bouquets_flowers_joins
  has_many :flowers, through: :bouquets_flowers_joins
end
