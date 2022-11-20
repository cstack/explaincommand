class ManpageParser
  def self.parse_html_string(html_string:, command_name:)
    html = Nokogiri::HTML(html_string)
    description = nil
    flags = []
    positional_arguments = []
    paragraphs = html.css('p')
    paragraphs.each do |paragraph|
      text = paragraph.text
      if paragraph_description?(text)
        description = extract_description_from_paragraph(text)
        next
      end
      if paragraph_synopsis?(text)
        positional_arguments = extract_positional_arguments_from_paragraph(text:, command_name:)
        next
      end
      flag = extract_flags(text)
      flags << flag unless flag.nil?
    end
    Manpage.new(
      description:,
      flags:,
      positional_arguments:
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
      flags:,
      positional_arguments: []
    )
  end

  def self.paragraph_description?(text)
    text.start_with?('NAME')
  end

  def self.paragraph_synopsis?(text)
    text.start_with?('SYNOPSIS')
  end

  def self.extract_description_from_paragraph(text)
    text.match(/^NAME\s+(.+)$/)[1]
  end

  def self.extract_flags(text)
    text.match(/\s\w+\s/)
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
    takes_argument = spacers.length > 1 && spacers[0].length == 1 && spacers[1].length > 1
    Flag.new(aliases:, description: text, takes_argument:)
  end

  def self.extract_positional_arguments_from_paragraph(text:, command_name:)
    words = text.split
    index_of_first_usage = words.index(command_name)
    index_of_second_usage = words[index_of_first_usage + 1, words.length].index(command_name)
    words_of_first_usage = if index_of_second_usage.nil?
                             words[index_of_first_usage, words.length]
                           else
                             words[index_of_first_usage, index_of_second_usage + 1]
                           end
    grouped_words = group_by_brackets(words_of_first_usage)
    positional_argument_words = grouped_words.drop(1).reject do |word|
      word.gsub('[', '').start_with?('-')
    end
    interpret_ellipses(positional_argument_words)
  end

  def self.group_by_brackets(words)
    result = []
    while words.length > 0
      word = words.shift
      word = "#{word} #{words.shift}" while word.count('[') > word.count(']') && words.length > 0
      result << word
    end
    result
  end

  def self.interpret_ellipses(words)
    result = []
    words.each do |word|
      if word == '...'
        result.last[:repeated] = true
      else
        result << {
          name: word,
          repeated: false
        }
      end
    end
    result
  end
end
