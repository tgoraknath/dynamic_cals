#Json validator provides core api's to validate a given json against given json-schema.
#for more details about json-schema, 
#refer to http://json-schema.org/latest/json-schema-validation.html#rfc.section.3.3

class JsonValidator

 def initialize
    #backward and forward compatability.
    @api_spec_schema = JSON.parse(File.read("./config/v4/api_spec_schema.json"))
 end 

 def validate_api_spec(api_spec_json)
  JSON::Validator.fully_validate(@api_spec_schema, api_spec_json, 
                                  :insert_defaults => true, :strict => true)
 end
=begin
  
fully_validate api is autodesk automation specification wrapped around json-schema specifications to perform
assertions. This api expects 3 json strings.
1. api_spec_json (Test Step value from jira) adhering to schema defined at api_spec_schema.json.
2. res_schema_json (Expected Result from Jira test case) adhering to API specification.
3. api_res is the API response in json format.

fully_validate validates the API status code to 200 by default otherwise as specified in Test Step.
fully_validate also validates the api_res against to res_schema_json.

It will return either a empy array(validation passed) or errors with details about failure.
  
=end
 def fully_validate(api_spec, res_schema_json, api_res)
  #errors = validate_api_spec(api_spec_json)
  #return errors unless errors.size.eql?(0)
  #api_spec = JSON.parse(api_spec_json)
  res_schema = res_schema_json
  is_array = api_spec["api_spec"]["array"] 
  is_strict = api_spec["api_spec"]["strict"]
  is_insert_defaults = api_spec["api_spec"]["insert_defaults"]
  api_spec_res_code = api_spec["api_spec"]["response_code"]
  api_spec_res_code = api_spec_res_code.nil? ? 200 : api_spec_res_code
  res_code = api_res.code
  res_body = api_res.body.nil? ? "{}" : api_res.body
  errors = JSON::Validator.fully_validate(res_schema, res_body, 
                :validate_schema => true,
                :list => is_array.nil? ? false : is_array,
                :insert_defaults => is_insert_defaults.nil? ? false : is_insert_defaults, 
                :strict => is_strict.nil? ? false : is_strict)
  errors << "api response code #{res_code} is not matching with api_sec response_code
  + #{api_spec_res_code}" unless res_code.to_i.eql?(api_spec_res_code)
  errors 
 end

end 
