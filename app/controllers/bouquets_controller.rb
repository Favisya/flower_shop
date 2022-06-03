class BouquetsController < ApplicationController
  before_action :find_flower, only: [:add_in_bouquet]
  before_action :find_bouquet, only: [:show, :destroy]
  skip_before_action :require_login, only: [:create, :new]
  $current_bouquet

  def new
    @bouquet = Bouquet.new
  end

  def flowerApi
    auth = { username: 'admin@favis', password: 'f38341fce0' }
    response = HTTParty.get('https://online.moysklad.ru/api/remap/1.2/entity/assortment', basic_auth: auth)
    @response_size_of_elements = response["meta"]["size"]
    size = @response_size_of_elements # size of all elements
    @response_obj = response.to_s
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
      flower.num = response["rows"][i]["stock"]

      flower.save
      i += 1

    end

    i = 0
    @flower = Flower.all

    @flower.each do |flower|
      flower.update_attribute(:num, response["rows"][i]["stock"])
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
      redirect_to "http://localhost:3000/bouquets/" + @bouquet.id.to_s
    else
      render :new
    end
  end

  def show
    flowerApi
    $current_bouquet = @bouquet
    @flower = Flower.all
    size = @bouquet.flowers.size

    full_price = 0
    i = 0
    while i < size do
      @bouquet.flowers[i]
      count = BouquetsFlowersJoin.find_by(flower_id: @bouquet.flowers[i].id, bouquet_id: $current_bouquet.id) # need to add count !!!
      full_price = full_price + @bouquet.flowers[i].price * count.counter

      i += 1
    end

    @price = full_price

  end

  def plus
    @flower = Flower.find(params[:id])
    newCount = BouquetsFlowersJoin.find_by(flower_id: @flower.id, bouquet_id: $current_bouquet.id).counter + 1
    object = BouquetsFlowersJoin.find_by(flower_id: @flower.id, bouquet_id: $current_bouquet.id)
    object.update_attribute(:counter, newCount)
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

  def index
    flowerApi
    if session[:id] == nil
      redirect_to sessions_path
    end

    if current_user.role.access == 1
      @bouquet = Bouquet.all
    end
    if current_user.role.access == 2 || current_user.role.access == 3
      @bouquet = Bouquet.where(shop_id: current_user.shop_point)
    end
  end

  def add_in_bouquet
    @flower = Flower.find(params[:id])
    if $current_bouquet.flowers.include?(@flower)
    else
      $current_bouquet.flowers << @flower
    end

    redirect_to($current_bouquet)
  end

  def remove

    if $current_bouquet.sold == false
      flower = $current_bouquet.flowers.find(params[:id])
      #$current_bouquet.flowers.delete(flower)
      $current_bouquet.flowers.delete(flower) #### Надо исправить удаление, Удаляются все одинаковеы элементы
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
      $current_bouquet.update_attribute(:sold, false)
    else
      $current_bouquet.update_attribute(:sold, true)
      #auth = { username: 'admin@favis', password: 'f38341fce0' }
      #response = HTTParty.get('https://online.moysklad.ru/api/remap/1.2/entity/assortment', basic_auth: auth)
      #@response_query = response
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
    params[:flower].permit(:flower_id, :name, :price, :ean13, :uuid, :code, :outCode, :num)
  end

  def find_bouquet
    @bouquet = Bouquet.find_by(id: params[:id])
  end

  def find_flower
    @flower = Flower.find(params[:id])
  end
end
