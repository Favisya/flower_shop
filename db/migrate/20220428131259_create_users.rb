class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users ,id: false do |t|
      t.string :login
      t.string :name
      t.string :surname
      t.string :email
      t.string :password_digest
      t.string :id
      t.string :shop_point
      t.integer :role_id
    end
  end
end
