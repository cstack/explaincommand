class Manpage
  def self.for_command(command)
    html_string = File.read(Rails.root.join("data/manpages/#{command}.html"))
    html = Nokogiri::HTML(html_string)
    result = {
      name: nil,
      flags: []
    }
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
