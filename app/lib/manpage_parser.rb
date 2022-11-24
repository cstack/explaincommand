class ManpageParser
  def self.parse_html_string(html_string:, command_name:)
    html = Nokogiri::HTML(html_string)
    description = extract_description(html)
    synopsis_text = extract_synopsis_text(html)
    positional_arguments = extract_positional_arguments_from_paragraph(text: synopsis_text, command_name:)
    flags = FlagParser.extract_flags(html)
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
