class ShopifyOrderTables < ActiveRecord::Migration[5.0]
  def change
    change_table :shopify_orders do |t|
      t.string :browser_ip
      t.string :cancel_reason
      t.datetime :cancelled_at
      t.string :cart_token
      t.datetime :closed_at
      t.datetime :order_created
      t.string :currency
      t.string :email
      t.string :financial_status
      t.string :fulfillment_status
      t.string :tags
      t.string :order_id
      t.string :landing_site
      t.string :location_id
      t.string :name
      t.string :note
      t.integer :number
      t.integer :order_number
      t.datetime :processed_at
      t.datetime :processing_method
      t.string :referring_site
      t.string :source_name
      t.float :subtotal_price
      t.boolean :taxes_included
      t.string :token
      t.float :total_discounts
      t.float :total_line_items_price
      t.float :total_price
      t.float :total_tax
      t.integer :total_weight
      t.datetime :order_updated_at
      t.string :user_id
      t.string :order_status_url
    end

    create_table :shopify_customers do |t|
      t.datetime :created
      t.integer :shopify_order_id

      t.boolean :accepts_marketing
      t.datetime :customer_created
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :customer_id
      t.string :note
      t.integer :orders_count
      t.string :state
      t.float :total_spent
      t.datetime :customer_updated
      t.string :tags
    end

    create_table :shopify_fulfillments do |t|
      t.datetime :created
      t.integer :shopify_order_id

      t.datetime :fulfillment_created
      t.string :fulfillment_id
      t.string :order_id
      t.string :status
      t.string :tracking_company
      t.string :tracking_number
      t.datetime :fulfillment_updated
    end

    create_table :shopify_line_items do |t|
      t.datetime :created
      t.integer :shopify_order_id

      t.integer :fulfillable_quantity
      t.string :fulfillment_service
      t.string :fulfillment_status
      t.integer :grams
      t.string :line_item_id
      t.float :price
      t.string :product_id
      t.integer :quantity
      t.boolean :requires_shipping
      t.string :sku
      t.string :title
      t.string :variant_id
      t.string :variant_title
      t.string :vendor
      t.string :name
      t.boolean :gift_card
      # skipped -- t.array :properties
      t.boolean :taxable
      # skipped -- t.array :tax_lines
      t.float :total_discount
    end

    create_table :shopify_shipping_addresses do |t|
      t.datetime :created
      t.integer :shopify_order_id

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
end
