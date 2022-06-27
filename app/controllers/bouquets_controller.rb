class BouquetsController < ApplicationController
  before_action :find_flower, only: [:add_in_bouquet]
  before_action :find_bouquet, only: [:show, :destroy]

  $current_bouquet

  require 'json'
  require 'httparty'
  #require 'crack'

  def new
    @bouquet = Bouquet.new
  end

  def flowerApi
    auth = { username: 'admin@favis', password: 'f38341fce0' } #Here change login and password
    response = HTTParty.get('https://online.moysklad.ru/api/remap/1.2/entity/assortment', basic_auth: auth)
    @response_size_of_elements = response["meta"]["size"]
    size = @response_size_of_elements #size of all elements
    @response_obj = response.to_s

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
      flower.num = response["rows"][i]["stock"]

      flower.save
      i += 1

    end

    i = 0
    @flower = Flower.all
    while i < @flower.size do
      Flower.find_by(flower_id: response["rows"][i]["id"]).update_attribute(:num, response["rows"][i]["stock"])
      i += 1
    end

  end

  def create

    @bouquet = Bouquet.new(bouquet_params)
    @bouquet.sold = false
    if current_user.role.access == 2 || current_user.role.access == 3
      @bouquet.shop_id = current_user.shop_point
    end
    if @bouquet.save
      redirect_to "/bouquets/" + @bouquet.id.to_s
    else
      render :new
    end
  end

  def bouquets_on_vitrine
    if current_user.role.access == 1
      @bouquet = Bouquet.where(:vitrine => true, :sold => false)
      @bouquet = @bouquet.sort_by { |obj| -obj.id }
    end
    if current_user.role.access == 2 || current_user.role.access == 3
      @bouquet = Bouquet.where(shop_id: current_user.shop_point, :vitrine => true, :sold => false)
      @bouquet = @bouquet.sort_by { |obj| -obj.id }
    end
  end

  def show
    flowerApi
    $current_bouquet = @bouquet
    @flower = Flower.all
    @counters = BouquetsFlowersJoin.all
    size = @bouquet.flowers.size

    full_price = 0
    i = 0
    while i < size do
      @bouquet.flowers[i]
      count = BouquetsFlowersJoin.find_by(flower_id: @bouquet.flowers[i].id, bouquet_id: $current_bouquet.id)
      full_price = full_price + @bouquet.flowers[i].price * count.counter

      i += 1
    end

    $current_bouquet.update_attribute(:price, full_price)
    @price = full_price

    @finder = Flower.search(params[:search])
  end

  def plus
    @flower = Flower.find(params[:id])
    if BouquetsFlowersJoin.find_by(flower_id: @flower.id, bouquet_id: $current_bouquet.id).counter < @flower.num
      newCount = BouquetsFlowersJoin.find_by(flower_id: @flower.id, bouquet_id: $current_bouquet.id).counter + 1
      object = BouquetsFlowersJoin.find_by(flower_id: @flower.id, bouquet_id: $current_bouquet.id)
      object.update_attribute(:counter, newCount)
    end
    redirect_to ($current_bouquet)
  end

  def minus
    @flower = Flower.find(params[:id])

    if BouquetsFlowersJoin.find_by(flower_id: @flower.id, bouquet_id: $current_bouquet.id).counter.to_int > 1
      newCount = BouquetsFlowersJoin.find_by(flower_id: @flower.id, bouquet_id: $current_bouquet.id).counter - 1
      object = BouquetsFlowersJoin.find_by(flower_id: @flower.id, bouquet_id: $current_bouquet.id)
      object.update_attribute(:counter, newCount)
    end

    redirect_to ($current_bouquet)
  end

  def update
    if @counters.update(join_params)
      redirect_to redirect_to ($current_bouquet)
    else
      render :show
    end
  end

  def save
    @bouquet = Bouquet.find(params[:id])
    $current_bouquet.update_attribute(:vitrine, true)
    if $current_bouquet.name == ''
      $current_bouquet.update_attribute(:name , "Витринный образец")
    end
    $current_bouquet.update_attribute(:number, "-")
    $current_bouquet.update_attribute(:address, "-")

    redirect_to ($current_bouquet)
  end

  def index
    if session[:id] == nil
      redirect_to sessions_path
    end

    if current_user.role.access == 1
      @bouquet = Bouquet.all
      @bouquet = @bouquet.sort_by { |obj| -obj.id }
    end
    if current_user.role.access == 2 || current_user.role.access == 3
      @bouquet = Bouquet.where(shop_id: current_user.shop_point)
      @bouquet = @bouquet.sort_by { |obj| -obj.id }
    end
  end

  def add_in_bouquet
    @flower = Flower.find(params[:id])
    if @flower.num > 0
      if $current_bouquet.flowers.include?(@flower)
      else
        $current_bouquet.flowers << @flower
      end
    end
    redirect_to($current_bouquet)
  end

  def remove

    if $current_bouquet.sold == false
      flower = $current_bouquet.flowers.find(params[:id])
      #$current_bouquet.flowers.delete(flower)
      $current_bouquet.flowers.delete(flower)
    end
    redirect_to($current_bouquet)

  end

  def remove_all

    if $current_bouquet.sold == false
      $current_bouquet.flowers.clear
    end
    redirect_to($current_bouquet)

  end

  def sold

    if $current_bouquet.sold == true
      #$current_bouquet.update_attribute(:sold, false)
    else
      positions = '['
      size = $current_bouquet.flowers.size
      i = 0
      while i < size do
        quantity = BouquetsFlowersJoin.find_by(flower_id: $current_bouquet.flowers[i].id, bouquet_id: $current_bouquet.id).counter
        positions += '{
          "quantity": ' + quantity.to_s; positions += ',
          "price": ' + $current_bouquet.flowers[i].price.to_s; positions += '00,
        "assortment" : {
        "meta": {
          "href": "https://online.moysklad.ru/api/remap/1.2/entity/product/' + $current_bouquet.flowers[i].flower_id.to_s; positions += '",
          "type": "product",
          "mediaType": "application/json"
        }
      },
      "reserve": ' + quantity.to_s; positions += '
      }'
        if i != size - 1
          positions += ','
        end

        i += 1
      end
      positions += ']'

      puts "flag1"
      puts positions.to_s
      @Position_Request = positions.to_s
      #puts @Position_Request

      auth = { username: 'admin@favis', password: 'f38341fce0' } #here change login password
      @query = HTTParty.post('https://online.moysklad.ru/api/remap/1.2/entity/customerorder', basic_auth: auth, :body => {
        "organization": {
          "meta": {
            "href": "https://online.moysklad.ru/api/remap/1.2/entity/organization/9434a1b6-dd05-11ec-0a80-02a70012a376", #Here change organization id
            "type": "organization",
            "mediaType": "application/json"
          }
        },
        "shipmentAddress": $current_bouquet.address.to_s,
        "description": "Номер: " + $current_bouquet.number.to_s + " Имя: " + $current_bouquet.name.to_s,
        "applicable": true,
        "vatEnabled": false,
        "agent": {
          "meta": {
            "href": "https://online.moysklad.ru/api/remap/1.2/entity/counterparty/94358a93-dd05-11ec-0a80-02a70012a37b", #Here change counterparty id
            "type": "counterparty",
            "mediaType": "application/json"
          }
        },
        "positions":
          JSON.parse(@Position_Request)
      }.to_json, :headers => {
        "Content-Type": "application/json"
      },)
      order_id = @query['meta']['href']
      puts order_id

      @transportQuery = HTTParty.post('https://online.moysklad.ru/api/remap/1.2/entity/demand', basic_auth: auth, :body => {
        "organization": {
          "meta": {
            "href": "https://online.moysklad.ru/api/remap/1.2/entity/organization/9434a1b6-dd05-11ec-0a80-02a70012a376", #Here change organization id
            "type": "organization",
            "mediaType": "application/json"
          }
        },
        "shipmentAddress": $current_bouquet.address.to_s,
        "description": "Номер: " + $current_bouquet.number.to_s + "Имя: " + $current_bouquet.name.to_s,
        "applicable": true,
        "vatEnabled": false,
        "agent": {
          "meta": {
            "href": "https://online.moysklad.ru/api/remap/1.2/entity/counterparty/94358a93-dd05-11ec-0a80-02a70012a37b", #Here change counterparty id
            "type": "counterparty",
            "mediaType": "application/json"
          }
        },
        "store": {
          "meta": {
            "href": "https://online.moysklad.ru/api/remap/1.2/entity/store/943572cc-dd05-11ec-0a80-02a70012a378", #Here change store id
            "type": "store",
            "mediaType": "application/json"
          }
        },
        "vatIncluded": true,
        "customerOrder": {
          "meta": {
            "href": order_id.to_s,
            "type": "customerorder",
            "mediaType": "application/json"
          }
        },
        "positions":
          JSON.parse(@Position_Request)
      }.to_json, :headers => {
        "Content-Type": "application/json"
      },)
      puts "flag4"
      puts @transportQuery.to_s

      $current_bouquet.update_attribute(:sold, true)

    end
    redirect_to($current_bouquet)
  end

  def destroy
    if @bouquet.destroy
      redirect_to bouquets_path
    else
      redirect_to bouquets_path, error: "Error in delete"
    end
  end

  private

  def bouquet_params

    params[:bouquet].permit(:address, :number, :sold, :name)
  end

  private

  def flower_params
    params[:flower].permit(:flower_id, :name, :price, :ean13, :uuid, :code, :outCode, :num, :search)
  end

  def find_bouquet
    @bouquet = Bouquet.find_by(id: params[:id])
  end

  def find_flower
    @flower = Flower.find(params[:id])
  end

  def join_params
    params[:BouquetsFlowersJoin].permit(:counter)
  end

end
