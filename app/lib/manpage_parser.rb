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

  def self.extract_positional_arguments_from_paragraph(text:, command_name:)
    first_usage = extract_first_usage_from_paragraph(text:, command_name:)
    UsageParser.extract_positional_arguments_from_usage_pattern(text: first_usage, command_name:)
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
end
