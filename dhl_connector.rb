require 'date'
require 'faraday'
require 'json'
require 'pry'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/cross_origin'
require 'time'

require './config/environments' # database configuration
require './models/models.rb'

class DhlKey
  SANDBOX_ID =
  SANDBOX_SECRET =
  SANDBOX_ACCESS_URL = "https://#{SANDBOX_ID}:#{SANDBOX_SECRET}@api-qa.dhlecommerce.com/v1/auth/accesstoken"
  SANDBOX_API = "https://api-qa.dhlecommerce.com/"
end

# Thread to check/update DHL API key
t_api_key = Thread.new do
  while true do
    puts "Checking log key...."
    AuthKey.update_api_key()
    puts "Key up to date...."
    sleep 1200
  end
end

# Thread to fetch open orders from Shopify API
#  and store to DB.
t_fetch_shopify = Thread.new do
  while true do
    puts "Fetching shopify orders...."
    Shopify.fetch_orders()
    puts "Done fetching orders...."
    sleep 600
  end
end

# Thread to send open orders over to DHL for fulfillment
t_dhl = Thread.new do
  while true do
    puts "Fulfilling orders..."
    Dhl.fulfill_orders()
    Dhl.track_fulfillments()
    sleep 600
  end
end

t_dhl = Thread.new do
  while true do
    puts "Tracking fulfilled orders..."

    sleep 600
  end
end
