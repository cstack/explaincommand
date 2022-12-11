class ManpageParser
  def self.parse_html_string(html_string:, command_name:)
    html = Nokogiri::HTML(html_string)
    description = extract_description(html)
    usage_text = extract_synopsis_text(html)
    usage_text = extract_usage_from_name_section(html) if usage_text.nil?
    positional_arguments = extract_positional_arguments_from_paragraph(text: usage_text, command_name:)
    flags = FlagParser.extract_flags(html)
    Manpage.new(
      command_name:,
      description:,
      flags:,
      positional_arguments:
    )
  end

  def self.extract_synopsis_text(html)
    section = html.css('h1#SYNOPSIS').first&.parent
    return nil if section.nil?

    section.css('h1').remove
    section.text
  end

  def self.extract_usage_from_name_section(html)
    section = html.css('h1#NAME').first&.parent
    return nil if section.nil?

    section.css('p')[1].text
  end

  def self.extract_description(html)
    html.css('h1#NAME').first.parent.css('p').first.text.split(' - ').last
  end

  def self.extract_positional_arguments_from_paragraph(text:, command_name:)
    text = text.strip.gsub(/\s/, ' ')
    first_usage = extract_first_usage_from_paragraph(text:, command_name:)
    UsageParser.extract_positional_arguments_from_usage_pattern(text: first_usage, command_name:)
  end

  # Given some text containing one or more usage patterns, return the text of the first usage pattern
  # A usage pattern looks like:
  #   git checkout [-q] [-f] [-m] [<branch>]
  def self.extract_first_usage_from_paragraph(text:, command_name:)
    words = text.split
    index_of_first_usage = words.index(command_name.main_command)
    rest_of_text = words[index_of_first_usage + command_name.num_words, words.length]
    index_of_second_usage = rest_of_text.index(command_name.main_command)
    words_of_first_usage = if index_of_second_usage.nil?
                             words[index_of_first_usage, words.length]
                           else
                             words[index_of_first_usage, index_of_second_usage + command_name.num_words]
                           end
    words_of_first_usage.join(' ')
  end
end
