class FlowersController < JSONAPI::ResourceController
  #JSONAPI::ResourceController
  require 'httparty'
  require 'crack'
  #  skip_before_action :verify_authenticity_token

  #request in Json for all available things
  def flowerApi
    auth = { username: 'admin@favis', password: 'f38341fce0' }
    response = HTTParty.get('https://online.moysklad.ru/api/remap/1.2/entity/assortment', basic_auth: auth)
    @response_size_of_elements = response["meta"]["size"]
    size = @response_size_of_elements # size of all elements
    @response_obj = response
    #@response_name = response["rows"][0]["barcodes"][0]["ean13"] #first element #testing
    i = 0
    while i < size do
      flower = Flower.new
      flower.name = response["rows"][i]["name"]
      flower.price = response["rows"][i]["salePrices"][0]["value"]
      flower.price /= 100
      flower.flower_id = response["rows"][i]["id"]
      flower.ean13 = response["rows"][i]["barcodes"][0]["ean13"]
      flower.code = response["rows"][i]["code"]
      flower.outCode = response["rows"][i]["externalCode"]
      flower.num = response["rows"][i]["stock"] ###########check it

      flower.save
      i += 1

    end
  end

end
