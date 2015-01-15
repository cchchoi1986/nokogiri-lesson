class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string :title
      t.text :address
      t.string :phonenumber
      t.string :pricerange
      t.text :tags
      t.text :acceptedpayment
      t.integer :seating
      t.text :intro
      t.text :description
      t.timestamps
    end
  end
end
