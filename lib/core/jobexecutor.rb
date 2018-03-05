=begin

JobExecutor class performs reading the test cases from jira.
JobExecutor supports parallel test cases execution and also supports multi-steps from each test case.
JobExecutor will skip the test case steps execution when there are errors fould with previous step.

=end
class JobExecutor

 def initialize
  @total_executions = 0
  @failed_executions = 0
  @j2jira = Jenkins2Jira.new
  @j2api = Jenkins2Api.new
  @j2apigee = Jenkins2Apigee.new
  @validator = JsonValidator.new
 end 
 
 def execute
   test_cases = @j2jira.read_test_cases
   @total_executions = test_cases.size
   access_token = @j2apigee.access_token
   executions = test_cases["executions"]
   Parallel.map(executions, in_threads: executions.size) do |test_case|
    issue_id = test_case["issueId"].to_s
    issue_key = test_case["issueKey"].to_s
    puts "Jira test case: #{issue_key}, Worker: #{Parallel.worker_number}"
    read_and_run(access_token, issue_key, issue_id) 
   end 
 end 

=begin

 read_and_run api read the test case from the given JIRA issue_key, creates a execution id,
 invokes the service end point and performs assertions rules from the test case.   
 
 read_and_run executed in its own thread.   
=end
 def read_and_run(access_token, issue_key, issue_id)
  errors = []
  execution_id = 0
  begin 
    test_steps = @j2jira.read_test_data(issue_key, issue_id)
    execution_id = @j2jira.new_execution(issue_key, issue_id)
    test_steps.each_with_index do |step, index|
     api_spec_json = JSON.parse(step["step"]) 
     errors = @validator.validate_api_spec(api_spec_json)
     return errors unless errors.size.eql?(0)
     api_req_body = step["data"]
     res_schema = step["result"]
     controls = api_spec_json["api_spec"]["controls"]
     delay_minutes = controls.nil? ? 0 : controls["delay_minutes"]
     return [] if delay_minutes.eql?(-1)
     puts "before sleep: #{Time.now}"
     sleep delay_minutes*60 unless delay_minutes.eql?(0)
     puts "after sleep #{Time.now}"
     errs = run_step(access_token, api_spec_json, api_req_body, res_schema)
     errors << "step #{index} failed with errors: #{errs.join('|')}" unless errs.size.eql?(0)
     #skip iteration when errors exists in a given step.
     break if errors.size > 0 
    end 
  rescue JSON::ParserError => pe
    errors << "error in test case, please check json format for Test Step, Test Data and Expected Result or the API response" 
  rescue Exception => e 
    puts "exception occured #{e}"
    errors << "something went wrong - #{e.message}"
  ensure
    puts "do we have errors for the Jira Issue: #{issue_key}? #{errors}"
    @failed_executions+= 1 unless errors.size.eql?(0)
    @j2jira.update_test_case(execution_id, issue_key, errors) unless execution_id.eql?(0)
    @j2jira.issue_comment(issue_key, errors) 
  end 
 end 

 def run_step(access_token, api_spec_json, api_req_body, res_schema)
  api_res = @j2api.api_response(access_token, api_spec_json, api_req_body)
  @validator.fully_validate(api_spec_json, res_schema, api_res)
 end 

 def failedTestCases
   @failed_executions
 end 

 def new_cycle_url
  @j2jira.new_cycle_url
 end 


end 
