class ShopifyOrder < ActiveRecord::Base
  has_one :shopify_billing_address
  has_one :shopify_customers
  has_many :shopify_fulfillments
  has_many :shopify_line_items
  has_one :shopify_shipping_address

  # created

  # browser_ip
  # cancel_reason
  # cancelled_at
  # cart_token
  # closed_at
  # order_created
  # currency
  # email
  # financial_status
  # fulfillment_status
  # tags
  # order_id
  # landing_site
  # location_id
  # name
  # note
  # number
  # order_number
  # processed_at
  # processing_method
  # referring_site
  # source_name
  # subtotal_price
  # taxes_included
  # token
  # total_discounts
  # total_line_items_price
  # total_price
  # total_tax
  # total_weight
  # order_updated_at
  # user_id
  # order_status_url

  def self.generate(json_order)
    shopify_order = self.new
    shopify_order.created = DateTime.now.new_offset(0)

    if ShopifyOrder.where(:order_id => json_order['id']).length != 0
      return nil
    end

    shopify_order.browser_ip = json_order['browser_ip']
    shopify_order.cancel_reason = json_order['cancel_reason']
    shopify_order.cancelled_at = json_order['cancelled_at'].nil? ? nil :  DateTime.parse(json_order['cancelled_at']).new_offset(0)
    shopify_order.cart_token = json_order['cart_token']
    shopify_order.closed_at = json_order['closed_at'].nil? ? nil : DateTime.parse(json_order['closed_at']).new_offset(0)
    shopify_order.order_created = DateTime.parse(json_order['created_at']).new_offset(0)
    shopify_order.currency = json_order['currency']
    shopify_order.email = json_order['email']
    shopify_order.financial_status = json_order['financial_status']
    shopify_order.fulfillment_status = json_order['fulfillment_status']
    shopify_order.tags = json_order['tags']
    shopify_order.order_id  = json_order['id']
    shopify_order.landing_site = json_order['landing_site']
    shopify_order.location_id = json_order['location_id']
    shopify_order.name = json_order['name']
    shopify_order.note = json_order['note']
    shopify_order.number = json_order['number']
    shopify_order.order_number = json_order['order_number']
    shopify_order.processed_at = json_order['processed_at'].nil? ? nil : DateTime.parse(json_order['processed_at']).new_offset(0)
    shopify_order.processing_method = json_order['processing_method']
    shopify_order.referring_site = json_order['referring_site']
    shopify_order.source_name = json_order['source_name']
    shopify_order.subtotal_price = json_order['subtotal_price'].to_f
    shopify_order.taxes_included = json_order['taxes_included']
    shopify_order.token = json_order['token']
    shopify_order.total_discounts = json_order['total_discounts'].to_f
    shopify_order.total_line_items_price = json_order['total_line_items_price'].to_f
    shopify_order.total_price = json_order['total_price'].to_f
    shopify_order.total_tax = json_order['total_tax'].to_f
    shopify_order.total_weight = json_order['total_weight'].to_i
    shopify_order.order_updated_at = json_order['order_updated_at'].nil? ? nil : DateTime.parse(json_order['order_updated_at']).new_offset(0)
    shopify_order.user_id = json_order['user_id']
    shopify_order.order_status_url = json_order['order_status_url']

    shopify_order.shipping_title = json_order['shipping_lines'][0]['title']

    ShopifyBillingAddress.generate(shopify_order, json_order['billing_address'])
    ShopifyCustomer.generate(shopify_order, json_order['customer'])
    json_order['fulfillments'].each{ |fulfillment| ShopifyFulfillment.generate(shopify_order, fulfillment) }
    json_order['line_items'].each{ |line_item| ShopifyLineItem.generate(shopify_order, line_item) }
    ShopifyShippingAddress.generate(shopify_order, json_order['shipping_address'])

    shopify_order.dhl_received = false
    shopify_order.dhl_fulfilled = false
    shopify_order.dhl_accepted = nil

    shopify_order.save!

  end
end

class ShopifyBillingAddress < ActiveRecord::Base
  belongs_to :shopify_orders

  # created
  # shopify_order_id

  # address_1
  # address_2
  # city
  # company
  # country
  # id
  # first_name
  # last_name
  # phone
  # province
  # zip
  # province_code
  # country_code
  # default

  def self.generate(shopify_order, json_billing)
    billing_address = self.new
    billing_address.created = DateTime.now.new_offset(0)
    billing_address.shopify_order_id = shopify_order.order_id # foreign key

    if ShopifyBillingAddress.where(:shopify_order_id => shopify_order.id).length != 0
      return nil
    end

    billing_address.address_1 = json_billing['address1']
    billing_address.address_2 = json_billing['address2']
    billing_address.city = json_billing['city']
    billing_address.company = json_billing['company']
    billing_address.country = json_billing['country']
    billing_address.first_name = json_billing['first_name']
    billing_address.last_name = json_billing['last_name']
    billing_address.phone = json_billing['phone']
    billing_address.province = json_billing['province']
    billing_address.zip = json_billing['zip']
    billing_address.province_code = json_billing['province_code']
    billing_address.country_code = json_billing['country_code']
    billing_address.default = json_billing['default']

    billing_address.save!
  end
end

class ShopifyCustomer < ActiveRecord::Base
  belongs_to :shopify_orders

  # created
  # shopify_order_id

  # accepts_marketing
  # customer_created
  # email
  # first_name
  # customer_id
  # last_name
  # note
  # orders_count
  # state
  # total_spent
  # customer_updated
  # tags

  def self.generate(shopify_order, json_customer)
    customer = self.new
    customer.created = DateTime.now.new_offset(0)
    customer.shopify_order_id = shopify_order.order_id # foreign key

    if ShopifyCustomer.where(:customer_id => json_customer['id']).length != 0
      return nil
    end

    customer.accepts_marketing = json_customer['accepts_marketing']
    customer.customer_created = DateTime.parse(json_customer['created_at']).new_offset(0)
    customer.email = json_customer['email']
    customer.first_name = json_customer['first_name']
    customer.last_name = json_customer['last_name']
    customer.customer_id = json_customer['id']
    customer.note = json_customer['note']
    customer.orders_count = json_customer['orders_count'].to_i
    customer.state = json_customer['state']
    customer.total_spent = json_customer['total_spent'].to_f
    customer.customer_updated = DateTime.parse(json_customer['updated_at']).new_offset(0)
    customer.tags = json_customer['tags']

    customer.save!
  end
end

class ShopifyFulfillment < ActiveRecord::Base
  belongs_to :shopify_orders

  # created
  # shopify_order_id

  # fulfillment_created
  # fulfillment_id
  # order_id
  # status
  # tracking_company
  # tracking_number
  # updated_at

  def self.generate(shopify_order, json_fulfillment)
    fulfillment = self.new
    fulfillment.created = DateTime.now.new_offset(0)
    fulfillment.shopify_order_id = shopify_order.order_id

    if ShopifyFulfillment.where(:fulfillment_id => json_fulfillment['id']).length != 0
      return nil
    end

    fulfillment.fulfillment_created = DateTime.parse(json_fulfillment['fulfillment_created']).new_offset(0)
    fulfillment.fulfillment_id = json_fulfillment['id']
    fulfillment.status = json_fulfillment['status']
    fulfillment.tracking_company = json_fulfillment['tracking_company']
    fulfillment.tracking_number = json_fulfillment['tracking_number']
    fulfillment.fulfillment_updated = json_fulfillment['updated_at']

    fulfillment.save!
  end
end

class ShopifyLineItem < ActiveRecord::Base
  belongs_to :shopify_orders

  # created
  # shopify_order_id

  # fulfillable_quantity
  # fulfillment_service
  # fulfillment_status
  # grams
  # line_item_id
  # price
  # product_id
  # quantity
  # requires_shipping
  # sku
  # title
  # variant_id
  # variant_title
  # vendor
  # name
  # gift_card
  # skipped - properties
  # taxable
  # skipped - tax_lines
  # total_discount
  # dhl_fulfilled

  def self.generate(shopify_order, json_line_item)
    line_item = self.new
    line_item.created = DateTime.now.new_offset(0)
    line_item.shopify_order_id = shopify_order.order_id

    # if line item ID already exists, don't save it
    if ShopifyLineItem.where(:line_item_id => json_line_item['id']).length != 0
      return nil
    # don't save if it includes "Sacred Uterus" in product title
    elsif json_line_item['title'].include? "Sacred Uterus"
      return nil
    end

    contains_special_char = ['\'','"', '>', '<', '&'].any? { |special_char| json_line_item['title'].include? special_char }
    line_item_title =  contains_special_char ? '' : json_line_item['title']

    line_item.fulfillable_quantity = json_line_item['fulfillable_quantity']
    line_item.fulfillment_service = json_line_item['fulfillment_service']
    line_item.fulfillment_status = json_line_item['fulfillment_status']
    line_item.grams = json_line_item['grams']
    line_item.line_item_id = json_line_item['id']
    line_item.price = json_line_item['price'].to_f
    line_item.product_id = json_line_item['product_id']
    line_item.quantity = json_line_item['quantity']
    line_item.requires_shipping = json_line_item['requires_shipping']
    line_item.sku = json_line_item['sku']
    line_item.title = line_item_title
    line_item.variant_id = json_line_item['variant_id']
    line_item.variant_title = json_line_item['variant_title']
    line_item.vendor = json_line_item['vendor']
    line_item.name = json_line_item['name']
    # SKIPPED line_item.properties = json_line_item['properties']
    line_item.gift_card = json_line_item['gift_card']
    line_item.taxable = json_line_item['taxable']
    # SKIPPED line_item.tax_lines = json_line_item['tax_lines']
    line_item.total_discount = json_line_item['total_discount'].to_f

    line_item.dhl_fulfilled = false

    line_item.save!
  end
end

class ShopifyShippingAddress < ActiveRecord::Base
  belongs_to :shopify_orders

  # created
  # shopify_order_id

  # address_1
  # address_2
  # city
  # company
  # country
  # country_code
  # first_name
  # last_name
  # name
  # phone
  # province
  # province_code
  # zip

  def self.generate(shopify_order, json_shipping)
    shipping_address = self.new
    shipping_address.created = DateTime.now.new_offset(0)
    shipping_address.shopify_order_id = shopify_order.order_id # foreign key

    if ShopifyShippingAddress.where(:shopify_order_id => shopify_order.id).length != 0
      return nil
    end

    shipping_address.address_1 = json_shipping['address1']
    shipping_address.address_2 = json_shipping['address2']
    shipping_address.city = json_shipping['city']
    shipping_address.company = json_shipping['company']
    shipping_address.country = json_shipping['country']
    shipping_address.first_name = json_shipping['first_name']
    shipping_address.last_name = json_shipping['last_name']
    shipping_address.phone = json_shipping['phone']
    shipping_address.province = json_shipping['province']
    shipping_address.zip = json_shipping['zip']
    shipping_address.province_code = json_shipping['province_code']
    shipping_address.country_code = json_shipping['country_code']
    shipping_address.default = json_shipping['default']

    shipping_address.save!
  end
end
