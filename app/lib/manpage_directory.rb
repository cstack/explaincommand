class ManpageDirectory
  class ManpageDoesNotExist < StandardError; end

  def self.get_manpage(command)
    if File.exist?(manpage_filepath(command))
      ManpageParser.parse_html_string(File.read(manpage_filepath(command)))
    elsif File.exist?(helppage_filepath(command))
      ManpageParser.parse_helppage_string(File.read(helppage_filepath(command)))
    else
      Manpage::UnknownCommand.new
    end
  end

  def self.manpage_exists?(command)
    File.exist?(manpage_filepath(command)) || File.exist?(helppage_filepath(command))
  end

  def self.manpage_filepath(command)
    Rails.root.join("data/manpages/#{command}.html")
  end

  def self.helppage_filepath(command)
    Rails.root.join("data/helppages/#{command}.txt")
  end
end
