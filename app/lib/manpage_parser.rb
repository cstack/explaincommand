class ManpageParser
  def self.parse_html_string(html_string)
    html = Nokogiri::HTML(html_string)
    name = nil
    flags = []
    paragraphs = html.css('p')
    paragraphs.each do |paragraph|
      text = paragraph.text
      if text.start_with?('NAME')
        name = text
      elsif text.start_with?('-')
        text = text.gsub("\n", ' ')
        matches = text.match(/(-[^\s]+)\s+(.+)/)
        if matches
          flag = matches[1]
          description = matches[2]
          flags << [flag, description]
        end
      end
    end
    Manpage.new(
      name:,
      flags:
    )
  end
end
