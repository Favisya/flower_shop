class Flower < ApplicationRecord
  validates :flower_id, uniqueness: true
  #has_and_belongs_to_many :bouquets
  has_many :bouquets_flowers_joins
  has_many :bouquets, through: :bouquets_flowers_joins
end