class ManpageDirectory
  class ManpageDoesNotExist < StandardError; end

  def self.get_manpage(command_name:, subcommand:)
    if manpage_exists?(command_name:, subcommand:)
      ManpageParser.parse_html_string(
        html_string: File.read(manpage_filepath(command_name:, subcommand:)),
        command_name:,
        subcommand:
      )
    elsif helppage_exists?(command_name:, subcommand:)
      ManpageParser.parse_helppage_string(
        helppage_string: File.read(helppage_filepath(command_name:, subcommand:)),
        subcommand:
      )
    else
      Manpage::UnknownCommand.new
    end
  end

  def self.exists?(command_name:, subcommand:)
    manpage_exists?(command_name:, subcommand:) || helppage_exists?(command_name:, subcommand:)
  end

  def self.manpage_exists?(command_name:, subcommand:)
    File.exist?(manpage_filepath(command_name:, subcommand:))
  end

  def self.helppage_exists?(command_name:, subcommand:)
    File.exist?(helppage_filepath(command_name:, subcommand:))
  end

  def self.manpage_filepath(command_name:, subcommand:)
    Rails.root.join("data/manpages/#{full_name(command_name:, subcommand:)}.html")
  end

  def self.helppage_filepath(command_name:, subcommand:)
    Rails.root.join("data/helppages/#{full_name(command_name:, subcommand:)}.txt")
  end

  def self.full_name(command_name:, subcommand:)
    if subcommand.nil?
      command_name
    else
      "#{command_name}-#{subcommand}"
    end
  end
end
