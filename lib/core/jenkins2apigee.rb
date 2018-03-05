=begin 

Jenkins2Apigee class has one major functinalities

1. connect to the apigee end point and collect access-token.

=end

class Jenkins2Apigee

  def access_token
    timestamp = Time.now.to_i
    signature = SignatureProvider.new.hash_signature(client_secret, callback + client_id, timestamp)
    url = URI(apigee_url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(url)
    request["authorization"] = authorization
    request["signature"] = signature
    request["timestamp"] = timestamp.to_s
    response = http.request(request)
    resp = JSON.parse(response.body)
    resp["access_token"]
  end

  private
    def client_id  
      @cid ||= ENV['CLIENT_ID'].to_s
    end

    def client_secret  
      @cs ||= ENV['CLIENT_SECRET'].to_s
    end

    def callback  
      @cb ||= ENV['CALLBACK'].to_s
    end

    def authorization  
      @auth ||= ENV['AUTHORIZATION'].to_s
    end

    def apigee_url  
      @url ||= ENV['APIGEE_OAUTH'].to_s
    end
end