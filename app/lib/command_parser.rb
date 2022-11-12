class CommandParser
  def self.parse(cmd)
    words = cmd.split
    command = words.shift
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
    {
      command:,
      flags:,
      arguments:
    }
  end
end
