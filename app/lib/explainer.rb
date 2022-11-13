class Explainer
  def self.explain(cmd)
    command_name = CommandParser.full_command(cmd.split)
    manpage = ManpageDirectory.get_manpage(command_name)
    command = CommandParser.parse(cmd, manpage:)
    Explanation.from_manpage(manpage:, command:)
  end

  def self.parse_man_page(string)
    result = {
      name: nil,
      flags: []
    }
    html = Nokogiri::HTML(string)
    paragraphs = html.css('p')
    paragraphs.each do |paragraph|
      text = paragraph.text
      if text.start_with?('NAME')
        result[:name] = text
      elsif text.start_with?('-')
        text = text.gsub("\n", ' ')
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
