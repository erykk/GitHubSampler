require "json"

class Input 

  def initialize(file_path)

    contents = File.open(file_path).read
    @json = JSON.parse(contents)

  end

  def to_query
    op = ''
    if @json.has_key? :query
      op += "q=#{@json[:query]} "
    end
    
    @json.each do |line|
      op += "#{line[0]}:#{line[1]} "
    end    
    op

  end

end

# puts Input.new('{"language": "Ruby", "sort":"stars"}').to_s