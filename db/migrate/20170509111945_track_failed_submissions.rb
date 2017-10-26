class TrackFailedSubmissions < ActiveRecord::Migration[5.0]
  def change
  	create_table :dhl_submission_errors do |t|
      t.datetime :created
      t.string :shopify_order_id
      t.string :description
      t.string :error_message
      t.string :json_log
    end

    change_table :shopify_orders do |t|
      t.string :dhl_submission
 	end
  end
end
