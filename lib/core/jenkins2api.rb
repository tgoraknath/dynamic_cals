=begin 

Jenkins2Api class has one major functinalities

1. connect to the API end point and collect response by making a HTTP/REST api call.

=end

class Jenkins2Api

  def api_response(access_token, api_spec_json, data)
   #api_spec_rules = JSON.parse(api_spec_json)

   api_endpoint = api_spec_json["api_endpoint"]
   endpoint = api_endpoint["host"] + api_endpoint["path_params"] + api_endpoint["query_params"]
   method = api_spec_json["api_spec"]["method"]
   timestamp = Time.now.to_i
   signature = SignatureProvider.new.hash_signature(client_secret, callback + access_token, timestamp)
   url = URI(endpoint.to_s) 
    if(method == "GET")
     request = Net::HTTP::Get.new(url)
    elsif(method == "PATCH")
     request = Net::HTTP::Patch.new(url) 
    elsif(method == "PUT")
     request = Net::HTTP::Put.new(url)
    elsif(method == "DELETE")
     request = Net::HTTP::Delete.new(url)  
    else
     request = Net::HTTP::Post.new(url)
    end 
   request.body = data
   request["content-type"] = 'application/json'
   request["authorization"] = "Bearer #{access_token}"
   request["signature"] = signature.to_s
   request["timestamp"] = timestamp.to_s
   http = Net::HTTP.new(url.host, url.port)
   http.use_ssl = true
   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
   http.request(request)
  end

private
  def callback  
    @cb ||= ENV['CALLBACK'].to_s
  end
  def client_secret  
    @cs ||= ENV['CLIENT_SECRET'].to_s
  end

end