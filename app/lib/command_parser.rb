class CommandParser
  def self.parse(cmd)
    words = cmd.split
    command = words.shift
    flags = []
    arguments = []
    while words.length > 0
      word = words.shift
      if word.start_with?("--")
        if word.include?("=")
          flags << word.split("=")
        else
          flags << word
        end
      elsif word.start_with?("-")
        chars = word.chars
        chars.shift
        flags += chars.map { |char| "-#{char}" }
      else
        arguments << word
      end
    end
    {
      command: command,
      flags: flags,
      arguments: arguments,
    }
  end
end