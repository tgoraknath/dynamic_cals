=begin 

Jenkins2Api class has one major functinalities

1. connect to the API end point and collect response json data from it.

=end

class Jenkins2Git 
  
 def self.attributes
    puts "git users are: #{ENV['REPO_USERS']}"
    puts "pull request id: #{pr_id}"
    puts "pull request url: #{pr_url}"
    puts "pull request comment: #{comment}"
    puts "pull request commit: #{commit}"
    puts "pull request src_branch: #{src_branch}"
    puts "pull request target_branch: #{target_branch}"
    puts "pull request author: #{author}"
 end  
  def self.has_pr
    pr_url.nil? ? false : true
  end

def self.pr_id  
    @pr ||= ENV['ghprbPullId']
end

def self.pr_url  
  @url ||= ENV['ghprbPullLink']
end

def self.pr_id  
  @pr ||= ENV['ghprbPullId']
end

def self.comment  
  @c ||= ENV['ghprbCommentBody']
end

def self.commit  
  @pr ||= ENV['ghprbActualCommit']
end

def self.author 
  @author ||= ENV['ghprbTriggerAuthorLogin']
  #ENV.each do |key, val|
    #puts "Key:#{key} and value #{val}"
  #end
end

def self.src_branch  
  @s_b ||= ENV['ghprbSourceBranch']
end

def self.target_branch  
  @t_b ||= ENV['ghprbTargetBranch']
end

end