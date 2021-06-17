require "optparse"

require_relative "input"
require_relative "app"

options = {}

OptionParser.new do |parser|
    parser.on("-f", "--file [FILEPATH]", "Path to file containing query.") do |x|
        options[:file_path] = x
    end

    parser.on("-s", "--sample [NUMBER]", "Number of repositories to include in sample.") do |x|
        options[:sample] = x
    end

    parser.on("-c", "--clone", "Clone repositories locally.") do |x|
        options[:clone] = true
    end

    parser.on("-t", "--token [FILEPATH] ", "GitHub API access token") do |x|
        options[:token] = x
    end

    parser.on("-o", "--output [PATH]", "Folder in which results will be stored.") do |x|
        options[:output] = x
    end

    parser.on("-l", "--log", "Writes repository details to repositories.json") do
        options[:log] = true
    end

    parser.banner = "Usage: app.rb [options]"
    parser.on("-h", "--help", "Display help") do ||
        puts parser
        exit
    end

end.parse!

if !options.has_key?(:file_path) | options[:file_path].nil?
    puts "Using default path for settings file."
    options[:file_path] = "./settings.json"
    if !File.exists?(options[:file_path])
        puts "Error - settings.json does not exist."
    end
end

if !options.has_key?(:token) | options[:token].nil?
    puts "Warining - GitHub API token might be required."
end

puts options
app = App.new(options)
input = Input.new(options[:file_path])
app.fetch_repos(input.to_query)

if options.has_key? :sample
    app.sample(options[:sample])
end

# if options.has_key? :log
#     app.log
# end

if options.has_key? :clone
    if options.has_key? :output
        app.clone
    else
        puts "Error, need output folder to clone."
    end
end

