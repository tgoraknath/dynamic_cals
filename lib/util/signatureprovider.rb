=begin
TODO - provide util method details
=end

class SignatureProvider
	
  def hash_signature(client_secret, base_str, timestamp)
  	#timestamp = Time.now.to_i
    hash  = OpenSSL::HMAC.digest('sha256', client_secret, 
            base_str + "#{timestamp}")
    Base64.encode64(hash).strip().to_s
  end
   
end