=begin
=end

class ReqResSchemaTest

  def initialize
    @api_spec_json = File.read("./test-data/req_schema_v4_test1.json")
    @validator = JsonValidator.new
  end 

  def basic_validation
    errors = @validator.validate_api_spec(@api_spec_json)
    puts "are there errors with request? #{errors}"
  end 
  
  def req_res_schemas_validations
    #puts "are there errors with req_res_schemas_validations test-1? #{test1}"
    puts "are there errors with req_res_schemas_validations test-2? #{test2}"
  end
  
  private

  def test1
   res_schema_json = File.read("./test-data/res_sample_schema.json")
   res_json = File.read("./test-data/res_sample_schema_test1.json") 
   validate(@api_spec_json, res_schema_json, res_json)
  end	

  def test2
   # req_schema_test2 has a strict validation set to true
   api_spec_json = File.read("./test-data/req_schema_v4_test2.json") 
   res_schema_json = File.read("./test-data/res_sample_schema.json")
   res_json = File.read("./test-data/res_sample_schema_test1.json") 
   validate(api_spec_json, res_schema_json, res_json)
  end

  def validate(api_spec_json, res_schema_json, res_json)
   @validator.fully_validate(api_spec_json, res_schema_json, res_json)
  end	

end
