class Dhl

  def self.fulfill_orders
    unfulfilled_orders = self.get_unfulfilled()
    unfulfilled_orders.each do |uf_order|
      self.fulfill_single(uf_order)
    end
  end

  def self.get_unfulfilled
    delay_time_mins = 5 # don't get orders in query unless they are older than this many mins.
    secs_ago = DateTime.now.new_offset(0).to_time.to_i - delay_time_mins*60
    mins_ago = Time.at(secs_ago).to_datetime.new_offset(0)
    ShopifyOrder.where(:dhl_received => false).all
  end

  def self.fulfill_single(uf_order)

    dhl_formatted_order = self.dhl_format(uf_order)
    unique_submission_code = "#{uf_order.order_number}" + (0...8).map { (65 + rand(26)).chr }.join
    dhl_formatted_order['CreateSalesOrder']['OrderSubmissionID'] = unique_submission_code
    dhl_auth_key = AuthKey.all.first.auth_token

    response = self.dhl_connection.post do |req|
      req.url "/efulfillment/v1/order"
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{dhl_auth_key}"
      req.body = dhl_formatted_order.to_json # sales order JSON GOES HERE
    end

    if response.status >= 200 && response.status < 300
      uf_order.dhl_received = true
      uf_order.dhl_submission = unique_submission_code
      uf_order.save!
    elsif response.status == 400
      dhl_submission_error = DhlSubmissionError.generate(uf_order, response.body)
    end
  end

  def self.dhl_connection
    Faraday.new(url: DhlKey::SANDBOX_API, ssl: { verify: false }) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.adapter  Faraday.default_adapter  # make requests with Net::https
    end
  end

  def self.dhl_format(uf_order)
    dhl_payload = {"CreateSalesOrder": nil}
    dhl_payload_base = {
      "MessageDateTime": DateTime.now.new_offset(0).to_s[0..18], # uct
      "OrderSubmissionID": nil,
      "AccountNumber": "5117452",
      "OrgID": "5117452", #skippable
      "Order": nil
    }
    dhl_payload_order = self.format_order_data(uf_order)

    dhl_payload_base["Order"] = dhl_payload_order
    dhl_payload["CreateSalesOrder"] = dhl_payload_base

    dhl_payload
  end

  def self.format_order_data(uf_order)

    dhl_billing = self.format_billing_data(uf_order)
    dhl_shipping = self.format_shipping_data(uf_order)
    dhl_order_line_items = self.format_line_items(uf_order)

    dhl_order = {
      "OrderHeader": {
        "OrderDateTime": uf_order.order_created.to_datetime.to_s[0..18],
        "OrderNumber": uf_order.order_number.to_s,
        "OrderReferenceNumber": "", # skipped
        "SalesChannel": "", # skipped
        "IsB2BOrder": "N",
        "ShippingServiceID": self.map_shipping_code(uf_order.shipping_title), # mapping from shipping title  to shipping code
        "ShippingServiceOption": "", #skipped
        "Charges":{ #all skippble
          "OrderCurrency": uf_order.currency,
          "OrderTotal": uf_order.total_price.to_s,
          "OrderSubTotal": uf_order.subtotal_price.to_s,
          "CODAmount": "0",
          "TotalOrderDiscount": uf_order.total_discounts.to_s,
          "TotalShippingCharge": "", # need to calculate this?....
          "TaxTotal": "", # need to calculate this?
          "TaxDetail": [], # skipped
          "ChargeDetail": [] # skipped
        },
        "PaymentMethods": {}, # skipped
        "BillTo": dhl_billing,
        "Shipto": dhl_shipping
      },
      "OrderDetails": {
        "OrderLine": dhl_order_line_items
      }
    }
  end

  def self.format_billing_data(uf_order)
    billing_address = ShopifyBillingAddress.where(:shopify_order_id => uf_order.order_id).first
    billing_payload = {
      "FirstName": billing_address.first_name,
      "LastName": billing_address.last_name,
      "AddressLine1": billing_address.address_1,
      "AddressLine2": billing_address.address_2,
      "AddressLine3": "",
      "City": billing_address.city,
      "State": billing_address.province_code,
      "ZipCode": billing_address.zip,
      "Country": billing_address.country_code,
      "PhoneNumber": billing_address.phone,
      "EmailID": uf_order.email
    }
  end

  def self.format_shipping_data(uf_order)
    shipping_address = ShopifyShippingAddress.where(:shopify_order_id => uf_order.order_id).first
    shipping_payload = {
      "FirstName": shipping_address.first_name,
      "LastName": shipping_address.last_name,
      "AddressLine1": shipping_address.address_1,
      "AddressLine2": shipping_address.address_2,
      "AddressLine3": "",
      "City": shipping_address.city,
      "State": shipping_address.province_code,  # ISO Covenvsion for US Only
      "ZipCode": shipping_address.zip,  # if no zip send 00000
      "Country": shipping_address.country_code,  # ISO Covenvsion
      "PhoneNumber": shipping_address.phone,
      "EmailID": uf_order.email
    }
  end

  def self.format_line_items(uf_order)
    line_items = ShopifyLineItem.where(:shopify_order_id => uf_order.order_id).all.sort { |sli| sli.created }
    line_items_payload = []

    line_items.each_with_index do |line_item, index|
      line_item_formatted = {
        "OrderLineNumber": index.to_s,
        "OrderedQuantity": line_item.quantity.to_s,
        "ItemID": line_item.sku,
        "ProductIDReference": "", #skippable
        "ItemDescription": line_item.title, # no special characters remove before sending
        "Price": line_item.price.to_s,
        "LineTotal": (line_item.price * line_item.quantity).to_s,
        "Instruction": [], # skippable
        "TaxDetail": [] # skippable
      }
      line_items_payload.push(line_item_formatted)
    end

    line_items_payload
  end

  def self.map_shipping_code(shipping_title)
    dhl_shipping_codes = {
      '2 Day Shipping' => 'FDE 2',
      'Free Shipping' => 'DECD 81',
      'Overnight Shipping' => 'FDE 1',
      'Overnight Shipping (Not available for PO boxes.)' => 'FDE 1',
      'Rush Shipping (1-2 business days)' => 'FDE 1',
      'Single Order Shipping' => 'DECD E',
      'Standard Shipping' => 'DECD E',
      'Standard Shipping (4-5 business days)' => 'DECD E',
      'Standard Trial Shipping' => 'DECD 81',
      'custom' => 'DECD 81'
    }

    if !dhl_shipping_codes.keys.include?(shipping_title)
      # TODO: create/log error in the event that a shipping title does not exist in this map
    end

    dhl_shipping_codes['shipping_title']
  end

  def self.track_fulfillments
    tracking_orders = ShopifyOrder.where(:dhl_received => true, :dhl_fulfilled => false, :dhl_accepted => nil).where("created < ?", mins_ago).all

    tracking_orders.each do |uf_order|
      self.check_fulfillment(uf_order)
    end
  end

  def self.check_fulfillment(uf_order)
    dhl_auth_key = AuthKey.all.first.auth_token

    response = self.dhl_connection.get do |req|
      req.url "/efulfillment/v1/order/acknowledgement/5117452/#{uf_order.order_number}/#{uf_order.dhl_submission}"
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{dhl_auth_key}"
    end

    json_response = JSON.parse(response['body'])
    order_status = json_response['CreationAcknolwedge']['Order']['OrderSubmission']['OrderCreationStatus']
    if order_status == 'Order Created'
      uf_order.dhl_accepted = true
      uf_order.save!
    else
      uf_order.dhl_accepted = false
      self.generate_rejected_fulfillment(uf_order, response['body'])
      uf_order.save!
    end

    # TODO: NEED TO DO SOMETHING THAT WILL SHOW/LOOK UP SUBMISSIONS WHERE THE ORDER WAS
    # INITIALLY ACCEPTED BUT REJECTED/LATER FAILED AT THIS STAGE.
  end

  class DhlSubmissionError < ActiveRecord::Base
    #  t.datetime :created
    #  t.string :shopify_order_id
    #  t.string :description
    #  t.string :error_message
    #  t.string :json_log

    def self.generate(unfulfilled_order, response_body)
      json_response = JSON.parse(response.body)
      failed_submission = DhlSubmissionError.new
      failed_submission.created = DateTime.now.new_offset(0)
      failed_submission.shopify_order_id = unfulfilled_order.order_id
      failed_submission.description = json_response['description']
      failed_submission.error_message = json_response['detailError']
      failed_submission.json_log = json_response['json_log']

      failed_submission.save!
    end

    def self.generate_rejected_fulfillment(unfulfilled_order, response_body)
      json_response = JSON.parse(response.body)
      error_descs = json_response['CreationAcknolwedge']['Order']['OrderSubmission']['Error'].map{ |dhl_error| dhl_error['ErrorDescription'] }.join(", ")

      failed_submission = DhlSubmissionError.new
      failed_submission.created = DateTime.now.new_offset(0)
      failed_submission.shopify_order_id = unfulfilled_order.order_id
      failed_submission.description = error_descs
      failed_submission.error_message = json_response['CreationAcknolwedge']['Order']['OrderSubmission']['OrderCreationStatus']
      failed_submission.json_log = json_response['CreationAcknolwedge']['Order']['OrderSubmission']['Error'].to_json

      failed_submission.save!
    end
  end

end
