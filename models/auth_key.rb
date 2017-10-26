class AuthKey < ActiveRecord::Base
  # created
  # auth_token
  # token_type
  # expires_in
  # scope

  def self.update_api_key
    current_auth_key = AuthKey.all.first
    valid_key = self.validate_auth_key(current_auth_key)
    if !valid_key
      self.generate_auth_key()
      puts "Generated new DHL key."
    else
      puts "DHL key still valid. No action taken."
    end
  end

  def self.validate_auth_key(auth_key)
    if auth_key.nil?
      return false
    end

    key_creation_time = auth_key.created.to_time.to_i
    key_duration = auth_key.expires_in
    current_time = Time.now.to_i

    if (key_creation_time + key_duration - 900) < current_time
      puts "Expired API key found. Generating a new one..."
      return false
    end
    return true
  end

  def self.generate_auth_key
    auth_key_conn = Faraday.new(url: DhlKey::SANDBOX_ACCESS_URL, ssl: { verify: false }) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.adapter  Faraday.default_adapter  # make requests with Net::https
    end

    response = auth_key_conn.get do |req|
      req.url ""
    end

    new_auth_key = JSON.parse(response.body)
    self.save_auth_key(new_auth_key)
  end

  def self.save_auth_key(new_auth_key)
    auth_key = AuthKey.all.first
    if auth_key.nil?
      auth_key = AuthKey.new
    end

    auth_key.created = DateTime.now.new_offset(0)
    auth_key.auth_token = new_auth_key['access_token']
    auth_key.token_type = new_auth_key['token_type']
    auth_key.expires_in = new_auth_key['expires_in']
    auth_key.scope = new_auth_key['scope']
    auth_key.save!

    auth_key
  end
end
