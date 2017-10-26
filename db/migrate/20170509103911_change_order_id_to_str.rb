class ChangeOrderIdToStr < ActiveRecord::Migration[5.0]
  def change
    change_column :shopify_billing_addresses, :shopify_order_id, :string
    change_column :shopify_customers, :shopify_order_id, :string
    change_column :shopify_fulfillments, :shopify_order_id, :string
    change_column :shopify_line_items, :shopify_order_id, :string
    change_column :shopify_shipping_addresses, :shopify_order_id, :string
  end
end
