class CreateShopifyBillingAddress < ActiveRecord::Migration[5.0]
  def self.up
    create_table :shopify_billing_addresses do |t|
      t.integer :shopify_order_id
      t.datetime :created
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :company
      t.string :country
      t.string :order_id
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :province
      t.string :zip
      t.string :province_code
      t.string :ountry_code
      t.boolean :default
    end
  end

  def self.down
    drop_table :shopify_orders
    drop_table :shopify_billing_addresses
  end

end
