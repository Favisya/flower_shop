class CreateFlowers < ActiveRecord::Migration[7.0]
  def change
    create_table :flowers do |t|
      t.string :name
      t.string :flower_id
      t.integer :price
      t.string :uuid
      t.string :code
      t.string :outCode
      t.string :ean13
      t.integer :num
      t.timestamps
    end
  end
end
