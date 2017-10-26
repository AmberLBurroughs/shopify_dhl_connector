class FixShopifyColumnTypo < ActiveRecord::Migration[5.0]
  def change
    change_table :shopify_billing_addresses do |t|
      t.rename :ountry_code, :country_code
    end

    change_table :shopify_shipping_addresses do |t|
      t.rename :ountry_code, :country_code
    end

    remove_column :shopify_billing_addresses, :billing_address_id
    remove_column :shopify_shipping_addresses, :shipping_address_id
  end
end
