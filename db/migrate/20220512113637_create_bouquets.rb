class CreateBouquets < ActiveRecord::Migration[7.0]
  def change
    create_table :bouquets do |t|
      t.string :address
      t.string :number
      t.string :name
      t.string :shop_id
      t.boolean :sold
      t.timestamps
    end
  end
end
