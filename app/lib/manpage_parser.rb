class ManpageParser
  def self.parse_html_string(html_string:, command_name:)
    html = Nokogiri::HTML(html_string)
    description = extract_description(html)
    synopsis_text = extract_synopsis_text(html)
    positional_arguments = extract_positional_arguments_from_paragraph(text: synopsis_text, command_name:)
    flags = extract_flags_from_description_section(html)
    flags += extract_flags_from_options_section(html)
    Manpage.new(
      command_name:,
      description:,
      flags:,
      positional_arguments:
    )
  end

  def self.extract_synopsis_text(html)
    synopsis_section = html.css('h1#SYNOPSIS').first.parent
    synopsis_section.css('h1#SYNOPSIS').remove
    synopsis_section.text.strip.gsub(/\s+/, ' ')
  end

  def self.extract_flags_from_description_section(html)
    rows = html.css('h1#DESCRIPTION').first.parent.css('dl').flat_map do |dl|
      extract_description_list(dl)
    end
    rows_with_flags = rows.select do |row|
      row.first.text.start_with?('-')
    end
    rows_with_flags.map do |row|
      flag_from_row(row)
    end
  end

  def self.extract_flags_from_options_section(html)
    options_section = html.css('h1#OPTIONS').first&.parent
    return [] if options_section.nil?

    options_section.css('p').select do |paragraph|
      paragraph.text.start_with?('-')
    end.map do |paragraph|
      aliases = paragraph.text.split(', ')
      description = paragraph.next.next.text
      Flag.new(aliases:, description:, takes_argument: false)
    end
  end

  def self.extract_description_list(description_list)
    result = []
    row = []
    expecting = 'dt'
    description_list.children.each do |child|
      next if child.name == 'text'
      raise "Malformed DL. Was expecting #{expecting} but found #{child.name}" if child.name != expecting

      row << child
      if expecting == 'dt'
        expecting = 'dd'
      else
        result << row
        row = []
        expecting = 'dt'
      end
    end
    raise 'Malformed DL' if expecting != 'dt'

    result
  end

  def self.flag_from_row(row)
    aliases_text = row.first.text.gsub(/\s+/, ' ')
    aliases = aliases_text.split(', ')
    description = row.second.text
    Flag.new(aliases:, description:, takes_argument: false)
  end

  def self.extract_description(html)
    html.css('h1#NAME').first.parent.css('p').first.text.split(' - ').last
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
    first_usage = extract_first_usage_from_paragraph(text:, command_name:)
    extract_positional_arguments_from_usage_pattern(text: first_usage, command_name:)
  end

  def self.extract_first_usage_from_paragraph(text:, command_name:)
    words = text.split
    index_of_first_usage = words.index(command_name.main_command)
    index_of_second_usage = words[index_of_first_usage + command_name.num_words, words.length].index(command_name.main_command)
    words_of_first_usage = if index_of_second_usage.nil?
                             words[index_of_first_usage, words.length]
                           else
                             words[index_of_first_usage, index_of_second_usage + command_name.num_words]
                           end
    words_of_first_usage.join(' ')
  end

  def self.extract_positional_arguments_from_usage_pattern(text:, command_name:)
    words = text.split
    num_words_in_command = command_name.num_words
    grouped_words = group_by_brackets(words)
    positional_argument_words = grouped_words.drop(num_words_in_command).reject do |word|
      word.gsub('[', '').start_with?('-') ||
        word == '[OPTIONS]'
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
      elsif word.include?('...')
        result << {
          name: word,
          repeated: true
        }
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
