class FlowerResource < JSONAPI::Resource
  attributes :flower_id, :name, :price, :ean13, :uuid, :code, :outCode, :num
end
