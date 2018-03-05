require "json-schema"
#require "rubygems"
# address should have "addrLine1", "city", "state","postalCode"
class String
def black;          "\e[30m#{self}\e[0m" end
def red;            "\e[31m#{self}\e[0m" end
def gray;           "\e[37m#{self}\e[0m" end


def bg_brown;       "\e[43m#{self}\e[0m" end
def bg_gray;        "\e[47m#{self}\e[0m" end
def bg_red;        "\e[41m#{self}\e[0m" end

def bold;           "\e[1m#{self}\e[22m" end
def blink;          "\e[5m#{self}\e[25m" end
def reverse_color;  "\e[7m#{self}\e[27m" end
end
schema = {
  "type"=>"object",
  "required" => ["addrLine1", "city", "state","postalCode"],
  "properties" => {
    "addrLine1" => {
      "type" => "string"
    },
    "city" => {
      "type" => "string"
    },
    "state" => {
      "type" => "string"
    },
    "postalCode" => {
      "type" => "string"
    }
  },
  "additionalProperties" => {
    "addrLine2" => {
      "type" => "string"
    },
    "country" => {
      "type" => "string"
     }
    }
  }
json = {
  "addrLine1":"4531 pisano terr",
  "addrLine2":"",
  "city":"dublin",
  "state":"ca",
  "postalCode":"94568",
  "country":""
}
# => true
puts ("Basic address json validation 1.: Press Enter to validate mandatory fields:" +  "addrLine1, city, state and postal code".red).bold.bg_gray
puts json.to_s.bold.bg_brown
gets.to_s
begin
  JSON::Validator.validate!(schema, json)
  puts "address json contains mandatory fields: addrLine1, city, state and postal code".bold.bg_gray
rescue JSON::Schema::ValidationError => e
  # here there is no error as schema and json are matching
  puts "Press Enter to know validation error messsages:"
  gets.to_s
  puts e.message
end
load "addr_test2.rb"



# => false
#flag = JSON::Validator.validate(schema, [{ "a" => 1, "b" => { "x" => 2 }, "c" => 3 }], [:list,:strict] => true)
#puts("flag is : #{flag}")
# => false
#flag = JSON::Validator.validate(schema, [{ "a" => 1 }], [:list,:strict] => true)
#puts("flag is : #{flag}")