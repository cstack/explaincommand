class ManpageDirectory
  class ManpageDoesNotExist < StandardError; end

  def self.get_manpage(command_name)
    if manpage_exists?(command_name)
      ManpageParser.parse_html_string(
        html_string: File.read(manpage_filepath(command_name)),
        command_name:
      )
    elsif helppage_exists?(command_name)
      ManpageParser.parse_helppage_string(
        helppage_string: File.read(helppage_filepath(command_name)),
        command_name:
      )
    else
      Manpage::UnknownCommand.new(command_name:)
    end
  end

  def self.exists?(command_name)
    manpage_exists?(command_name) || helppage_exists?(command_name)
  end

  def self.manpage_exists?(command_name)
    File.exist?(manpage_filepath(command_name))
  end

  def self.helppage_exists?(command_name)
    File.exist?(helppage_filepath(command_name))
  end

  def self.manpage_filepath(command_name)
    Rails.root.join("data/manpages/#{command_name.with_dashes}.html")
  end

  def self.helppage_filepath(command_name)
    Rails.root.join("data/helppages/#{command_name.with_dashes}.txt")
  end
end
