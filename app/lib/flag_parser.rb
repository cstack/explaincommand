class FlagParser
  def self.extract_flags(html)
    flags = []
    flags += extract_flags_from_dl_in_description_section(html)
    flags += extract_flags_from_alternating_p_and_div_in_options_section(html)
    flags
  end

  def self.extract_flags_from_dl_in_description_section(html)
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

  def self.extract_flags_from_alternating_p_and_div_in_options_section(html)
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
end
