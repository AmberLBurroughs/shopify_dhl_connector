class ShopifyOrderBase < ActiveRecord::Migration[5.0]
  create_table :shopify_orders do |t|
    t.datetime :created
  end
end
