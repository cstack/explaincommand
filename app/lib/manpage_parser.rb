class ManpageParser
  def self.parse_html_string(html_string:, command_name:)
    # Some manpages have nonbreaking spaces
    normalized = html_string.gsub(/&#x00A0;/, ' ')
    html = Nokogiri::HTML(normalized)
    description = extract_description(html)
    usages = extract_usages(html)
    usage = extract_first_usage(text: usages, command_name:)
    positional_arguments = UsageParser.extract_positional_arguments_from_usage_pattern(text: usage, command_name:)
    flags = FlagParser.extract_flags(html)
    Manpage.new(
      command_name:,
      description:,
      flags:,
      positional_arguments:
    )
  end

  # Given some text containing one or more usage patterns, return the text of the first usage pattern
  # A usage pattern looks like:
  #   git checkout [-q] [-f] [-m] [<branch>]
  def self.extract_first_usage(text:, command_name:)
    words = text.split
    num_words_in_first_usage = 0
    words.each_with_index do |word, i|
      next if i < command_name.num_words

      if word == command_name.main_command
        num_words_in_first_usage = i + 2 if words[i + 1] == '...'
        break
      else
        num_words_in_first_usage = i + 1
      end
    end
    words_of_first_usage = words[0, num_words_in_first_usage]
    words_of_first_usage.join(' ')
  end

  def self.extract_usages(html)
    text = extract_synopsis_text(html) || extract_usage_from_name_section(html)
    text.strip.gsub(/\s/, ' ')
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
end
