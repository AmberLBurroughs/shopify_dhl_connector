class UpdateDhlFulfillmentProperties < ActiveRecord::Migration[5.0]
  def change
  	change_table :shopify_orders do |t|
      t.boolean :dhl_accepted
    end

    change_table :shopify_line_items do |t|
      t.boolean :dhl_fulfilled
    end
  end
end
