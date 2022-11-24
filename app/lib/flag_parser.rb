class FlagParser
  def self.extract_flags(html)
    format_class = identify_format(html)
    if format_class.nil?
      []
    else
      format_class.new(html).extract_flags
    end
  end

  def self.identify_format(html)
    [
      Format1,
      Format2,
      Format3,
      Format4
    ].find do |format_class|
      format = format_class.new(html)
      format.matches_document?
    end
  end

  def self.parse_flag_definition(text)
    aliases = text.split(', ')
    last_alias = aliases.pop
    if last_alias.include?(' ')
      aliases << last_alias.split.first
      takes_argument = true
    else
      aliases << last_alias
      takes_argument = false
    end

    {
      aliases:,
      takes_argument:
    }
  end

  class Format
    attr_reader :html

    def initialize(html)
      @html = html
    end

    def description_section
      html.css('h1#DESCRIPTION').first&.parent
    end

    def options_section
      html.css('h1#OPTIONS').first&.parent
    end

    def extract_description_list(description_list)
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

    def flag_from_row(row)
      aliases_text = row.first.text.gsub(/\s+/, ' ')
      result = FlagParser.parse_flag_definition(aliases_text)
      aliases = result[:aliases]
      takes_argument = result[:takes_argument]
      description = row.second.text
      Flag.new(aliases:, description:, takes_argument:)
    end
  end

  class Format1 < Format
    # Flags are in a <dl> element in the description section
    def matches_document?
      !description_section.nil? && description_section.css('dl').length > 0
    end

    def extract_flags
      rows = description_section.css('dl').flat_map do |dl|
        extract_description_list(dl)
      end
      rows_with_flags = rows.select do |row|
        row.first.text.start_with?('-')
      end
      rows_with_flags.map do |row|
        flag_from_row(row)
      end
    end
  end

  class Format2 < Format
    # Flags are in alternating <p> and <div> elements in the options section
    def matches_document?
      return false if options_section.nil?

      options_section.css('p').any? do |paragraph|
        paragraph.text.start_with?('-') && paragraph.next.next.name == 'div'
      end
    end

    def extract_flags
      options_section.css('p').select do |paragraph|
        paragraph.text.start_with?('-')
      end.map do |paragraph|
        result = FlagParser.parse_flag_definition(paragraph.text)
        aliases = result[:aliases]
        takes_argument = result[:takes_argument]
        description = paragraph.next.next.text
        Flag.new(aliases:, description:, takes_argument:)
      end
    end
  end

  class Format3 < Format
    # Flags and their descriptions are in a single <p> tag.
    # Flag name and arguments are separated from description by <br>
    def matches_document?
      return false if options_section.nil?

      num_paragraphs = options_section.css('p').length
      return false if num_paragraphs == 0

      num_divs = options_section.css('div').length
      (num_paragraphs - num_divs).abs > 10
    end

    def extract_flags
      flags = []
      options_section.css('p').each do |paragraph|
        text = paragraph.text
        next unless text.start_with?('-')

        flag_usage = text.split("\n").first
        result = FlagParser.parse_flag_definition(flag_usage)
        aliases = result[:aliases]
        takes_argument = result[:takes_argument]
        description = text.split("\n").drop(1).join(' ').gsub(/\s+/, ' ').strip
        flags << Flag.new(
          aliases:, description:, takes_argument:
        )
      end
      flags
    end

    def options_section
      html.css('h1#OPTIONS').first&.parent
    end
  end

  class Format4 < Format
    # Flags are in a <dl> element in the OPTIONS section
    def matches_document?
      !options_section.nil? && options_section.css('dl').length > 0
    end

    def extract_flags
      rows = options_section.css('dl').flat_map do |dl|
        extract_description_list(dl)
      end
      rows_with_flags = rows.select do |row|
        row.first.text.start_with?('-')
      end
      rows_with_flags.map do |row|
        flag_from_row(row)
      end
    end
  end
end
