class TrackDhlFulfillment < ActiveRecord::Migration[5.0]
  def change
    change_table :shopify_orders do |t|
      t.boolean :dhl_received
      t.boolean :dhl_fulfilled
    end
  end
end
