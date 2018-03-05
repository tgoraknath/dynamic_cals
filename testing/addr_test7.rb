=begin
1. Move String class to common module file in lib folder with a file common.rb
2. require relative path in this file
3. Create a class AddressTest
4. move hard coded files like schema and json into test folder or config folders
5. initialize class Address and load schema and json into the objects
   example:
   class Address
     include Common
     def initialize
       @schema = JSON.parse(File.read("path/to/schema.json"))
       @json = JSON.parse(File.read("path/to/json_file.json"))
     end 

     def validate_address
       # All the validation code goes into this method
     end 

   end  

   Address.new.validate_address   

  6. Apart from this I would prefer below folder structure of adsk-automation 

  qe-automation
    -	app 
     >	can have all module specific folders or business logic 
    -	config
     >	config folder/files
    -	lib
     >	Contains all the common folders/files
    -	test
     >	ruby specs for unit testing
    -	app.rb
     >	is the file for trigger point for application to run
=end

class AddrTest7

  def initialize
    @schema = JSON.parse(File.read("./test-data/addr_schema_7.json"))
    @json = JSON.parse(File.read("./test-data/addr_test_7.json"))
  end 

  def validate_address
    puts "Press enter to view next example: "
    #gets.to_s
    puts ("get all address json validation 7.:").bold.bg_gray
    puts @json.to_s.bold.bg_brown
    puts "Press enter to validate:".bold.red
    #gets.to_s
    errors = JSON::Validator.fully_validate(@schema, @json, :list => true)
    puts "given array/list json has these errors: #{errors}".red if(errors.size > 0)
    puts "Great! evaluated all most all possible json validations ".gray
  end 

end
#AddrTest7.new.validate_address
