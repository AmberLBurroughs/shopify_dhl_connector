# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170512083109) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auth_keys", force: :cascade do |t|
    t.datetime "created"
    t.string   "auth_token"
    t.string   "token_type"
    t.integer  "expires_in"
    t.string   "scope"
  end

  create_table "dhl_submission_errors", force: :cascade do |t|
    t.datetime "created"
    t.string   "shopify_order_id"
    t.string   "description"
    t.string   "error_message"
    t.string   "json_log"
  end

  create_table "shopify_billing_addresses", force: :cascade do |t|
    t.string   "shopify_order_id"
    t.datetime "created"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "company"
    t.string   "country"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "province"
    t.string   "zip"
    t.string   "province_code"
    t.string   "country_code"
    t.boolean  "default"
  end

  create_table "shopify_customers", force: :cascade do |t|
    t.datetime "created"
    t.string   "shopify_order_id"
    t.boolean  "accepts_marketing"
    t.datetime "customer_created"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "customer_id"
    t.string   "note"
    t.integer  "orders_count"
    t.string   "state"
    t.float    "total_spent"
    t.datetime "customer_updated"
    t.string   "tags"
  end

  create_table "shopify_fulfillments", force: :cascade do |t|
    t.datetime "created"
    t.string   "shopify_order_id"
    t.datetime "fulfillment_created"
    t.string   "fulfillment_id"
    t.string   "status"
    t.string   "tracking_company"
    t.string   "tracking_number"
    t.datetime "fulfillment_updated"
  end

  create_table "shopify_line_items", force: :cascade do |t|
    t.datetime "created"
    t.string   "shopify_order_id"
    t.integer  "fulfillable_quantity"
    t.string   "fulfillment_service"
    t.string   "fulfillment_status"
    t.integer  "grams"
    t.string   "line_item_id"
    t.float    "price"
    t.string   "product_id"
    t.integer  "quantity"
    t.boolean  "requires_shipping"
    t.string   "sku"
    t.string   "title"
    t.string   "variant_id"
    t.string   "variant_title"
    t.string   "vendor"
    t.string   "name"
    t.boolean  "gift_card"
    t.boolean  "taxable"
    t.float    "total_discount"
    t.boolean  "dhl_fulfilled"
  end

  create_table "shopify_orders", force: :cascade do |t|
    t.datetime "created"
    t.string   "browser_ip"
    t.string   "cancel_reason"
    t.datetime "cancelled_at"
    t.string   "cart_token"
    t.datetime "closed_at"
    t.datetime "order_created"
    t.string   "currency"
    t.string   "email"
    t.string   "financial_status"
    t.string   "fulfillment_status"
    t.string   "tags"
    t.string   "order_id"
    t.string   "landing_site"
    t.string   "location_id"
    t.string   "name"
    t.string   "note"
    t.integer  "number"
    t.integer  "order_number"
    t.datetime "processed_at"
    t.datetime "processing_method"
    t.string   "referring_site"
    t.string   "source_name"
    t.float    "subtotal_price"
    t.boolean  "taxes_included"
    t.string   "token"
    t.float    "total_discounts"
    t.float    "total_line_items_price"
    t.float    "total_price"
    t.float    "total_tax"
    t.integer  "total_weight"
    t.datetime "order_updated_at"
    t.string   "user_id"
    t.string   "order_status_url"
    t.boolean  "dhl_received"
    t.boolean  "dhl_fulfilled"
    t.string   "dhl_submission"
    t.string   "shipping_title"
    t.boolean  "dhl_accepted"
  end

  create_table "shopify_shipping_addresses", force: :cascade do |t|
    t.datetime "created"
    t.string   "shopify_order_id"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "company"
    t.string   "country"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "province"
    t.string   "zip"
    t.string   "province_code"
    t.string   "country_code"
    t.boolean  "default"
  end

end
