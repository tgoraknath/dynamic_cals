=begin
  
QeAutomation executes automation test cases written in Jira.
  
=end
require 'json-schema'
require 'base64'
require 'json'
require 'net/http'
require 'time'
require "base64"
require 'openssl'
require 'pp'
require 'uri'
require 'open-uri'
require 'parallel'
#require 'nokogiri'
#require 'dotenv'
#require 'rest-client'
#require 'trollop'
#require 'rspec'
require_relative "../lib/util/color" 
require_relative "../lib/util/signatureprovider"
require_relative "../lib/core/jenkins2jira"
require_relative "../lib/core/jenkins2api"
require_relative "../lib/core/jenkins2apigee"
require_relative "../lib/core/jsonvalidator"
require_relative "../lib/core/jobexecutor"
require_relative "../lib/core/jenkins2git"

class QeAutomation

 def initialize
  puts "QeAutomation started..."
  ENV["REPO_USERS"] = ARGV[0]
  puts "Git Event attributes are: #{Jenkins2Git.attributes}"
  @job_executor = JobExecutor.new
 end 	

  def main
	  @job_executor.execute
    # NOTE: below puts statement is an input for jenkins job to complete execution successfully.
    puts "#{@job_executor.new_cycle_url}" + "@" + "#{@job_executor.failedTestCases}"
  end	
end

QeAutomation.new.main
