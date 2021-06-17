require "octokit"
require "git"
require "fileutils"

require_relative "input"

# repos = client.search_repos("language:ruby size:<1000")
# puts repos.total_count

# repos.items.each do |repo| 
#     puts repo.full_name
# end

class App 
  
  def initialize(options)
    access_token = get_access_token(options[:token]) unless options[:token].nil?

    @client = Octokit::Client.new(
      :access_token =>  options[:token],
      :auto_traversal => true,
      :auto_pagination => true
    )
    @options = options
  end

  def get_access_token(token)

    if token.include?(".")
      return token.to_str
    end

    IO.read(token).to_str
  end

  def fetch_repos(query)
    @result = @client.search_repos(query)
    @repos = @result.items
    puts @result.total_count
  end

  def sample(size)
    puts "Sample of size #{size}"
    @repos = @result.items.sample(size.to_i)
  end

  def clone
    if !File.directory? @options[:output]
      FileUtils.mkdir_p @options[:output]
    end

    @repos.each do |repo|
      clone_repo(repo.full_name)
    end
  end

  # def log
  #   File.open("./repositories.json", "w") do |file|
  #     @repos.each do |repo|
  #       file.write(repo.to_json)
  #     end
  #   end
  # end

  private

  def clone_repo(repo_name)
    if !File.directory? "#{@options[:output]}/#{repo_name}"
      FileUtils.mkdir_p "#{@options[:output]}/#{repo_name}"
    end
    puts "Cloning repository #{repo_name} into #{@options[:output]}/#{repo_name}"
    gh_stem = "https://github.com/"
    Git.clone("#{gh_stem}#{repo_name}", "#{@options[:output]}/#{repo_name}")
  end

end