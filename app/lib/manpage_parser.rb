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
        next
      end
      flag = extract_flags(text)
      flags << flag unless flag.nil?
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
      flag = extract_flags(text)
      flags << flag unless flag.nil?
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
    flags_with_match_data = text.enum_for(:scan, /--?[\w-]+/).map do |flag|
      match_data = Regexp.last_match
      [flag, match_data]
    end
    flags_with_match_data_at_beginning = flags_with_match_data.select do |_flag, match_data|
      match_data.begin(0) < first_non_flag_position
    end
    return nil if flags_with_match_data_at_beginning.length == 0

    aliases = flags_with_match_data_at_beginning.map(&:first)
    where_flags_end = flags_with_match_data_at_beginning.last.last.end(0)
    text_after_flags = text[where_flags_end, text.length]
    spacers = text_after_flags.scan(/\s+/)
    takes_argument = if spacers.length > 1 && spacers[0].length == 1 && spacers[1].length > 1
                       true
                     else
                       false
                     end
    Flag.new(aliases:, description: text, takes_argument:)
  end
end
