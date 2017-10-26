class StoreShippingLineItem < ActiveRecord::Migration[5.0]
  def change
    change_table :shopify_orders do |t|
      t.string :shipping_title
    end
  end
end
