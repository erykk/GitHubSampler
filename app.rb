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

  #{repo.full_name.split("/")[1]}

  def get_access_token(token)

    if token.include?(".")
      return token.to_str
    end

    IO.read(token).to_str
  end

  def save_details
    details_output_dir = "#{@output_dir}/details"
    if !File.directory? details_output_dir
      FileUtils.mkdir_p details_output_dir
    end

    puts "Writing details"
    repo_hash = Hash.new
    @repos.each do |repo|
      file_name = repo.full_name.split("/")[1]
      FileUtils.touch "./#{details_output_dir}/#{file_name}.json"
      File.open( "./#{details_output_dir}/#{file_name}.json", "w+") { |f| f.write(extract_json(repo).to_json) }
    end
  end

  def extract_json(resource)
    obj = Hash.new
    resource.each do |e|
      obj[e[0]] = e[1]
    end
    obj
  end

  def fetch_repos(query)
    puts query
    @result = @client.search_repos(query)
    @repos = @result.items
    puts @result.total_count
  end

  def sample(size)
    puts "Sample of size #{size}"
    @repos = @result.items.sample(size.to_i)
  end

  def clone
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
    output_dir = "#{@output_dir}/clones/#{repo_name}"
    if !File.directory? output_dir
      FileUtils.mkdir_p output_dir
    end
    puts "Cloning repository #{repo_name} into output_dir"
    gh_stem = "https://github.com/"
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
    remove_dir @output_dir
    FileUtils.mkdir_p @output_dir
  end

  def remove_dir(dir)
    FileUtils.rm_rf dir unless !File.directory?(dir)
  end

end