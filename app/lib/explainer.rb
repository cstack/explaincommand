class Explainer
  def self.explain(cmd)
    parsed_arguments = parse_command_line_arguments(cmd)
    command = parsed_arguments[:command]
    parsed_man_page = parse_man_page(read_man_page(command))
    Explanation.from_manpage(manpage: parsed_man_page, parsed_arguments: parsed_arguments)
  end

  def self.parse_command_line_arguments(cmd)
    words = cmd.split
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

  def self.read_man_page(command)
    File.read(Rails.root.join("data/manpages/#{command}.html"))
  end

  def self.parse_man_page(string)
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
end