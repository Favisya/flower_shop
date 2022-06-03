class CreateBouquetsFlowersJoins < ActiveRecord::Migration[7.0]
  def change
    create_table :bouquets_flowers_joins do |t|
      t.integer :flower_id, index: true
      t.integer :bouquet_id, index: true
      t.integer :counter , default: 1
      t.index [:flower_id, :bouquet_id], name: 'post_user_un', unique: true
    end
  end
end
