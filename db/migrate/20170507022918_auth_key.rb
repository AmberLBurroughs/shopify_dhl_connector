class AuthKey < ActiveRecord::Migration[5.0]
  create_table :auth_keys do |t|
    t.datetime :created
    t.string   :auth_token
    t.string   :token_type
    t.integer  :expires_in
    t.string   :scope
  end
end
