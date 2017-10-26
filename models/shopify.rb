class Shopify

  class ShopifyKey
    KEY =
    PASSWORD =
    SHOP_NAME = 'the-flex-company'
    BASE_URL = "https://#{KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com"
  end


  def self.fetch_orders
    # use a cutoff date.
    # iterate through all orders from the last queried order.
    # take each order and shove them into the database.
      # - if there is a certain SKU or product title that does not match,
      # we will skip the order (or line item)
    latest_order_date = last_ordered_date()
    new_orders = self.query_shopify(latest_order_date)
    self.store_orders(new_orders)
  end

  def self.last_ordered_date
    latest_order = self.latest_stored_order
    if latest_order.nil?
      # if no latest order, set starting date here.
      latest_order_date = DateTime.parse('2017-05-12').new_offset(0)
    else
      latest_order_date = latest_order.order_created
    end

    latest_order_date
  end

  def self.latest_stored_order
    ShopifyOrder.order('order_created ASC').where('order_created IS NOT NULL').last
  end

  def self.query_shopify(latest_order_date)
    shopify_conn = self.shopify_connection()
    count = self.incoming_order_count(latest_order_date)
    unfulfilled_orders = self.incoming_orders(latest_order_date, count)
  end

  def self.shopify_connection
    Faraday.new(url: ShopifyKey::BASE_URL, ssl: { verify: false }) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.adapter  Faraday.default_adapter  # make requests with Net::https
    end
  end

  def self.incoming_order_count(latest_order_date)
    response = self.shopify_connection.get do |req|
      req.url "/admin/orders/count.json"
      req.params['created_at_min'] = latest_order_date.to_s
      req.params['financial_status'] = 'paid'
      req.params['limit'] = 250
    end

    JSON.parse(response.body)['count']
  end

  def self.incoming_orders(latest_order_date, count=250)
    unfulfilled_orders = []
    page = 1

    while count > 0
      response = self.shopify_connection.get do |req|
        req.url "/admin/orders.json"
        req.params['created_at_min'] = latest_order_date.to_s
        req.params['page'] = page
        req.params['financial_status'] = 'paid'
        req.params['limit'] = 250
      end

      api_orders = JSON.parse(response.body)['orders']
      unfulfilled_orders.push(api_orders)
      page += 1
      count -= 250
    end

    api_orders
  end

  def self.store_orders(new_orders)
    # RUN THIS ONE LINE BELOW ONLY (COMMENT THE REST OUT) IF YOU
    # JUST WANT TO STORE A SINGLE ORDER IN THE DATABASE TO
    # TEST THE FULFILLMENT PROCESS.
    # saved_order = ShopifyOrder.generate(new_orders.first)

    new_orders.each do |new_order|
      shopify_order = ShopifyOrder.generate(new_order)

      ### GENERATE A NEW ORDER OBJECT AND SAVE ALL SUBPROPERTIES
      ### CHECK IF ITS JUST A TSHIRT/NON FLEX PRODUCT, IF SO IGNORE ORDER.
    end
  end

end
