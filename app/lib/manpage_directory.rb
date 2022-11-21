class ManpageDirectory
  class ManpageDoesNotExist < StandardError; end

  def self.get_manpage(command_name)
    if exists?(command_name)
      Manpage.from_json(File.read(manpage_filepath(command_name)))
    else
      Manpage::UnknownCommand.new(command_name:)
    end
  end

  def self.exists?(command_name)
    File.exist?(manpage_filepath(command_name))
  end

  def self.manpage_filepath(command_name)
    Rails.root.join("data/manpages/#{command_name.with_dashes}.json")
  end
end
