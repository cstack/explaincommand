class ManpageDirectory
  class ManpageDoesNotExist < StandardError; end

  def self.get_manpage(command)
    raise ManpageDoesNotExist, "Manpage for command `#{command}` does not exist" unless manpage_exists?(command)

    ManpageParser.parse_html_string(File.read(filepath(command)))
  end

  def self.manpage_exists?(command)
    File.exist?(filepath(command))
  end

  def self.filepath(command)
    Rails.root.join("data/manpages/#{command}.html")
  end
end
