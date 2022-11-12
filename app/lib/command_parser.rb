class CommandParser
  def self.parse(cmd)
    words = cmd.split
    command = full_command(words)
    flags = []
    arguments = []
    while words.length > 0
      word = words.shift
      if word.start_with?('--')
        flags << if word.include?('=')
                   word.split('=')
                 else
                   word
                 end
      elsif word.start_with?('-')
        chars = word.chars
        chars.shift
        flags += chars.map { |char| "-#{char}" }
      else
        arguments << word
      end
    end
    Command.new(
      name: command,
      flags:,
      arguments:
    )
  end

  def self.full_command(words)
    command = words.shift
    while words.length > 0
      command_to_check = "#{command}-#{words.first}"
      return command unless ManpageDirectory.manpage_exists?(command_to_check)

      command = command_to_check
      words.shift

    end
    command
  end
end
