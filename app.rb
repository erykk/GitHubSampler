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
    create_results_dir
  end

  def get_access_token(token)

    if !token.include?(".")
      return token.to_str
    end

    IO.read(token).to_str
  end

  def save_details

    repo_hash = Hash.new

    details_output_dir = "#{@output_dir}/details"
    create_new_dir details_output_dir    
    
    @repos.each do |repo|
      puts "Writing details for repository #{repo.full_name}"
      file_name = repo.full_name.split("/")[1]
      FileUtils.touch "./#{details_output_dir}/#{file_name}.json"
      File.open( "./#{details_output_dir}/#{file_name}.json", "w+") { |f| f.write(extract_json(repo).to_json) }
    end
  end

  def extract_json(resource)
    obj = Hash.new
    resource.map{ |k, v| obj[k] = v }
    obj
  end

  def fetch_repos(query)
    begin
      @result = @client.search_repos(query)
    rescue Octokit::Unauthorized
      puts "Octokit Error 401 - Bad Credentials"
      exit 
    end
    @repos = @result.items
    puts "Repositories matchig query {#{query}} -> #{@result.total_count}"
  end

  def sample(size)
    @repos = @result.items.sample(size.to_i)
  end

  def clone
    @repos.each do |repo|
      clone_repo(repo.full_name)
    end
  end

  private

  def clone_repo(repo_name)
    output_dir = "#{@output_dir}/clones/#{repo_name}"
    gh_stem = "https://github.com/"
    create_new_dir output_dir
    puts "Cloning repository #{repo_name} into output_dir"    
    begin
      Git.clone("#{gh_stem}#{repo_name}", "#{output_dir}")
    rescue Git::GitExecuteError
      puts "An error occurred during cloning of repository #{output_dir}"
    end
  end

  def dir_provided?
    !@options[:output].nil?    
  end

  def create_results_dir
    @output_dir = dir_provided? ? @options[:output] : "./output"
    create_new_dir @output_dir
  end

  def remove_dir(dir)
    FileUtils.rm_rf dir unless !File.directory?(dir)
  end

  def create_dir(dir)
    FileUtils.mkdir_p dir unless File.directory?(dir)
  end

  def create_new_dir(dir)
    remove_dir dir
    create_dir dir
  end

end