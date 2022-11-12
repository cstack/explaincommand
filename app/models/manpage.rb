class Manpage
  attr_reader :flags, :name

  def initialize(name:, flags:)
    @name = name
    @flags = flags
  end

  def ==(other)
    name == other.name &&
      flags == other.flags
  end

  def self.from_string(html_string)
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
    new(
      name:,
      flags:
    )
  end

  def self.from_json(json_string)
    new(**JSON.parse(json_string).transform_keys(&:to_sym))
  end
end
