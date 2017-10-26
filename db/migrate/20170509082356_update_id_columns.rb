class UpdateIdColumns < ActiveRecord::Migration[5.0]
  def change
    change_table :shopify_billing_addresses do |t|
      t.rename :order_id, :billing_address_id
    end

    remove_column :shopify_fulfillments, :order_id

    change_table :shopify_shipping_addresses do |t|
      t.rename :order_id, :shipping_address_id
    end
  end
end
