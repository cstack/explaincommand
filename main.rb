require "nokogiri"
require "json"

def read_man_page(command)
  File.read("man-pages/#{command}.html")
end

def parse_command_line_arguments(string)
  words = string.split
  command = words.shift
  flags = []
  arguments = []
  while words.length > 0
    word = words.shift
    if word.start_with?("--")
      if word.include?("=")
        flags << word.split("=")
      else
        flags << word
      end
    elsif word.start_with?("-")
      chars = word.chars
      chars.shift
      flags += chars.map { |char| "-#{char}" }
    else
      arguments << word
    end
  end
  {
    command: command,
    flags: flags,
    arguments: arguments,
  }
end

def parse_man_page(string)
  result = {
    name: nil,
    flags: [],
  }
  html = Nokogiri::HTML(string)
  paragraphs = html.css("p")
  paragraphs.each do |paragraph|
    text = paragraph.text
    if text.start_with?("NAME")
      result[:name] = text
    elsif text.start_with?("-")
      text = text.gsub("\n", " ")
      matches = text.match(/(-[^\s]+)\s+(.+)/)
      if matches
        flag = matches[1]
        description = matches[2]
        result[:flags] << [flag, description]
      end
    end
  end
  result
end

def explain_command_line_arguments(string)
  parsed_command_line_arguments = parse_command_line_arguments(string)
  command = parsed_command_line_arguments[:command]
  parsed_man_page = parse_man_page(read_man_page(command))
  parsed_command_line_arguments[:flags].map do |provided_flag|
    parsed_man_page[:flags].find do |man_flag|
      man_flag[0] == provided_flag
    end
  end
end

require 'socket'
require 'rack'
require 'rack/lobster'

def serve
  app = Proc.new do |env|
    if env["PATH_INFO"] == "/explain"
      args = Rack::Utils.parse_nested_query(env["QUERY_STRING"])
      if args["cmd"].nil?
        ['400', {'Content-Type' => 'text/html'}, ["Make a request to /explain?cmd=foo"]]
      else
        cmd = args["cmd"]
        explanation = explain_command_line_arguments(cmd)
        ['200', {'Content-Type' => 'text/html'}, [explanation.to_s]]
      end
    else
      ['404', {'Content-Type' => 'text/html'}, ["Make a request to /explain?cmd=foo"]]
    end
  end
  server = TCPServer.new 5678
   
  puts "Listening on http://localhost:5678/"
  while session = server.accept
    request = session.gets
    puts request
   
    # 1
    method, full_path = request.split(' ')
    # 2
    path, query = full_path.split('?')
   
    # 3
    status, headers, body = app.call({
      'REQUEST_METHOD' => method,
      'PATH_INFO' => path,
      'QUERY_STRING' => query
    })
   
    session.print "HTTP/1.1 #{status}\r\n"
    headers.each do |key, value|
      session.print "#{key}: #{value}\r\n"
    end
    session.print "\r\n"
    body.each do |part|
      session.print part
    end
    session.close
  end
end

if __FILE__ == $0
    serve
end
 
