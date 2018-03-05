=begin 

Jenkins2Jira class has 5 major functinalities

1. connect to the consumer specific project at autodesk.jira.com
2. create a new cycle to hold test case results for review/reference etc.
3. read the test cases from the given Test Cycles(refer to the JIRA_SRC_TEST_CYCLE)
4. execute each test case(invoke api), run result/response json through automation framework and hold results.
5. write the execution status to either to jira and/or to console  and/or to the PR and/or ALL
	((refer to the JIRA_DEST_TEST_CYCLE or RunOnEnv from configuration/setup).

=end

class Jenkins2Jira
	JIRA_HOST = "https://jira.autodesk.com".freeze
  CONTENT_TYPE = "application/json".freeze
  AUTH_BASIC = "Authorization: Basic ".freeze

	
	NEW_CYCLE = "/rest/zapi/latest/cycle".freeze
  NEW_CYCLE_URL = "/secure/enav/#?".freeze
  READ_TEST_CASES = "/rest/zapi/latest/zql/executeSearch?zqlQuery=project = ".freeze
  READ_TEST_DATA = "/rest/zapi/latest/teststep/".freeze
  EXECUTION = "/rest/zapi/latest/execution/".freeze
  ISSUE_COMMENT_URI = "/rest/api/2/issue/".freeze

  def initialize
    new_cycle
  end 

  def headers_attrs
  	@headers ||= " -H \"#{AUTH_BASIC}#{basic_auth.strip}\" -H \"Content-Type: #{CONTENT_TYPE}\" "
  end

  def new_cycle
  	@new_cycle_id ||= new_cycle_identifier
  end

  def read_test_cases
    test_cases_url = URI::encode("#{JIRA_HOST + READ_TEST_CASES + jira_proj_id} AND fixVersion = #{ts_src_verid}")
    data = `curl -X GET #{test_cases_url + headers_attrs}`
    JSON.parse(`curl -X GET #{test_cases_url + headers_attrs}`)
    #test_cases=JSON.parse(test_cases)
  end

  def read_test_data(issue_key, issue_id)
    test_input_data = `curl -X GET #{JIRA_HOST + READ_TEST_DATA + issue_id + headers_attrs}`
    #currently supported one step per jira test case.
    #test_data = JSON.parse(test_input_data)[0]
    JSON.parse(test_input_data)
  end

  def new_execution(issue_key, issue_id)
    e = `curl -X POST -d '{ "cycleId": #{new_cycle}, "issueId": #{issue_id}, "projectId": #{jira_proj_id}, "versionId": #{ts_results_verid}, "assigneeType": "", "assignee": "#{jira_username}" }' #{JIRA_HOST + EXECUTION + headers_attrs}` 
    JSON.parse(e).keys[0].to_s  
  end  

  def issue_comment(issue_key, errors) 
    flag = errors.size.eql?(0) ? "passed without" : "failed with"
    errors = "this #{issue_key} #{flag} errors: #{errors.join(',')}"
  	`curl -X POST -d '{"body": \"#{errors}\"}' #{JIRA_HOST + ISSUE_COMMENT_URI + issue_key}/comment#{headers_attrs}`
  end

  def update_test_case(execution_id, issue_key, errors)
    status = errors.size.eql?(0) ? 1 : 2
    `curl -X PUT -d '{"status": \"#{status}\"}' #{JIRA_HOST + EXECUTION}#{execution_id}/execute#{headers_attrs}`
  end
  
  def new_cycle_url
    JIRA_HOST + NEW_CYCLE_URL + URI::encode(@new_cycle_url)
  end

  private
    def new_cycle_identifier  
      t = Time.now.strftime('%v:%H:%M:%S')
      pr = ENV['ghprbPullId']
      pr = pr.nil? ? "_" : "_#{pr}_"
      cycle_name = ENV['JOB_NAME'] + pr + t
      c = `curl -X POST -d '{"versionId": #{ts_results_verid},"environment": "","build": "","name": "#{cycle_name}","description": "#{t}","projectId": #{jira_proj_id}}' #{JIRA_HOST + NEW_CYCLE + headers_attrs}`
      @new_cycle_url = "query=project in (#{jira_proj_id}) AND fixVersion in (#{ts_results_verid}) AND cycleName in (#{cycle_name}) "
      JSON.parse(c)["id"].to_s
    end

    def jira_proj_id  
      @jpid ||= ENV['JIRA_PROJ_ID'].to_s
    end

    def ts_src_verid  
      @tssvid ||= ENV['TEST_SUITE_SRC_VERSION'].to_s
    end

    def ts_results_verid  
      @tsrvid ||= ENV['TEST_SUITE_DESTINATION_VERSION'].to_s
    end

    def basic_auth
      @auth ||= Base64.encode64(ENV['JIRA_CREDENTIALS'].to_s)
    end

    def jira_username
      #JIRA_CREDENTIALS = "username:pswd"
      #@j_un ||= ENV['JIRA_CREDENTIALS'].split(':')[0]
      puts "initiator or GIT user: #{initiator}"
      @j_un ||= initiator
    end

    def initiator
      #can be one of: 
      #PR/PR-comment owner or 
      #one who triggered the jenkins job build or 
      #api attribute-initiator
      pr_i ||= ENV['ghprbTriggerAuthorLogin']
      pr_i.nil? ? ENV['INITIATOR'] : pr_i
    end
   
end