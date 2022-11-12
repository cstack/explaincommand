class ManpageParser
  def self.parse_html_string(html_string)
    html = Nokogiri::HTML(html_string)
    description = nil
    flags = []
    paragraphs = html.css('p')
    paragraphs.each do |paragraph|
      text = paragraph.text
      if is_paragraph_description?(text)
        description = text
      elsif flags_in_paragraph = extract_flags(text); flags_in_paragraph.length > 0
                                                      flags_in_paragraph.each do |flag|
                                                        flags << [flag, text]
                                                      end
      end
    end
    Manpage.new(
      description:,
      flags:
    )
  end

  def self.parse_helppage_string(helppage_string)
    lines = helppage_string.split("\n")
    description = nil
    flags = []
    lines.each do |line|
      next if line.blank?
      next if line.start_with?('Usage:')

      description = line
      break
    end
    lines.each do |text|
      next unless flags_in_paragraph = extract_flags(text) flags_in_paragraph.length > 0
   flags_in_paragraph.each do |flag|
        flags << [flag, text]
      end
    end
    Manpage.new(
      description:,
      flags:
    )
  end


  def self.is_paragraph_description?(text)
    text.start_with?('NAME')
  end

  def self.extract_flags(text)
    first_non_flag = text.match(/\s\w+\s/)
    first_non_flag_position = Regexp.last_match&.begin(0) || text.length
    flags_with_positions = text.enum_for(:scan, /--?[\w-]+/).map do |flag|
      position = Regexp.last_match.begin(0)
      [flag, position]
    end
    flags_with_positions.select do |_flag, position|
      position < first_non_flag_position
    end.map(&:first)
  end
end
