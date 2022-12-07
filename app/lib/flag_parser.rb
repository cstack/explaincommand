class FlagParser
  def self.extract_flags(html)
    [
      AlternatingParagraphAndDescriptionList,
      DescriptionList,
      ParagraphWithBr,
      ParagraphAndDiv
    ].flat_map do |extractor|
      extractor.new(html).extract_flags
    end.flatten.uniq(&:aliases).select do |flag|
      flag.aliases.all? do |alias_text|
        alias_text.start_with?('-')
      end
    end
  end

  def self.parse_flag_definition(text)
    aliases = text.split(', ')
    aliases = aliases.map do |alias_definition|
      if alias_definition.include?(' ')
        {
          alias: alias_definition.split[0],
          argument_type: Flag::ArgumentType::SEPARATED_BY_SPACE
        }
      elsif (match_result = alias_definition.match(/(.+)\[=(.+)\]/))
        {
          argument_type: Flag::ArgumentType::OPTIONAL_SEPARATED_BY_EQUAL_SIGN,
          alias: match_result[1]
        }
      elsif (match_result = alias_definition.match(/(.+)=(.+)/))
        {
          argument_type: Flag::ArgumentType::SEPARATED_BY_EQUAL_SIGN,
          alias: match_result[1]
        }
      else
        {
          argument_type: Flag::ArgumentType::NONE,
          alias: alias_definition
        }
      end
    end

    aliases.each do |alias_definition|
      break unless alias_definition[:argument_type] == Flag::ArgumentType::NONE

      alias_definition[:argument_type] = aliases.last[:argument_type]
    end

    aliases.group_by do |alias_definition|
      alias_definition[:argument_type]
    end.map do |argument_type, group|
      {
        aliases: group.pluck(:alias),
        argument_type:
      }
    end
  end

  def self.parse_flag_description(description_element)
    description = description_element.children[0].text.gsub(/\s+/, ' ').strip
    max_length = 500
    description_element.children.drop(1).each do |child|
      to_add = child.text.gsub(/\s+/, ' ').strip
      return description if description.length + to_add.length > max_length

      description += " #{to_add}"
    end
    description
  end

  class Extractor
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
      aliases = result.fetch(:aliases)
      argument_type = result.fetch(:argument_type)
      description = FlagParser.parse_flag_description(row.second)
      Flag.new(aliases:, description:, argument_type:)
    end
  end

  class AlternatingParagraphAndDescriptionList < Extractor
    def extract_flags
      html.css('p + dl').map do |dl|
        paragraph = dl.previous
        paragraph = paragraph.previous while paragraph.name == 'text'
        dt = dl.css('dt').first
        dd = dl.css('dd').first
        [paragraph, dt, dd]
      end.select do |paragraph, dt, dd|
        paragraph.text.present? && dt.text.blank? && dd.text.present?
      end.map do |paragraph, _dt, dd|
        aliases_text = paragraph.text.gsub(/\s+/, ' ')
        result = FlagParser.parse_flag_definition(aliases_text)
        description = FlagParser.parse_flag_description(dd)
        result.map do |alias_definition|
          aliases = alias_definition.fetch(:aliases)
          argument_type = alias_definition.fetch(:argument_type)
          Flag.new(aliases:, description:, argument_type:)
        end
      end
    end
  end

  class DescriptionList < Extractor
    def extract_flags
      html.css('dl').flat_map do |dl|
        flags_from_dl(dl)
      end
    end

    def flags_from_dl(dl_element)
      dl_element.css('dt').flat_map do |dt|
        flags_from_dt(dt)
      end
    end

    def flags_from_dt(dt_element)
      dd = dt_element.next
      dd = dd.next while dd.name != 'dd'
      return [] unless dt_element.text.present? && dd.text.present?

      aliases_text = dt_element.text.gsub(/\s+/, ' ')
      result = FlagParser.parse_flag_definition(aliases_text)
      description = FlagParser.parse_flag_description(dd)
      result.map do |alias_definition|
        aliases = alias_definition.fetch(:aliases)
        argument_type = alias_definition.fetch(:argument_type)
        Flag.new(aliases:, description:, argument_type:)
      end
    end
  end

  class ParagraphWithBr < Extractor
    def extract_flags
      html.css('p').flat_map do |paragraph|
        flags_from_paragraph(paragraph)
      end
    end

    def flags_from_paragraph(paragraph)
      result = paragraph.css('br').flat_map do |_br|
        text = paragraph.text
        return [] unless text.start_with?('-')

        flag_usage = text.split("\n").first
        result = FlagParser.parse_flag_definition(flag_usage)
        description = text.split("\n").drop(1).join(' ').gsub(/\s+/, ' ').strip
        result.map do |alias_definition|
          aliases = alias_definition.fetch(:aliases)
          argument_type = alias_definition.fetch(:argument_type)
          Flag.new(
            aliases:, description:, argument_type:
          )
        end
      end
    end
  end

  class ParagraphAndDiv < Extractor
    def extract_flags
      html.css('p + div').flat_map do |div|
        paragraph = div.previous
        paragraph = paragraph.previous while paragraph.name != 'p'
        flags_from_paragraph(paragraph, div)
      end
    end

    def flags_from_paragraph(paragraph, div)
      flag_usage = paragraph.text
      return [] unless flag_usage.start_with?('-')

      result = FlagParser.parse_flag_definition(flag_usage)
      description = div.text.gsub(/\s+/, ' ')
      result.map do |alias_definition|
        aliases = alias_definition.fetch(:aliases)
        argument_type = alias_definition.fetch(:argument_type)
        Flag.new(
          aliases:, description:, argument_type:
        )
      end
    end
  end
end
