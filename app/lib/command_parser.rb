class CommandParser
  def self.parse(cmd, manpage: nil)
    words = cmd.split
    command = full_command(words)
    flags = []
    arguments = []
    tokens = categorize_words(words)
    tokens = expand_combined_short_flags(tokens)
    tokens = interpret_equal_signs(tokens)
    tokens = assign_arguments(tokens:, manpage:)
    while tokens.length > 0
      token = tokens.shift
      if %i[shortflag longflag].include?(token[:type])
        flags << if token[:value].nil?
                   token[:text]
                 else
                   [token[:text], token[:value]]
                 end
      else
        arguments << token[:text]
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

  def self.categorize_words(words)
    words.map do |word|
      if word.start_with?('--')
        {
          type: :longflag,
          text: word
        }
      elsif word.start_with?('-')
        {
          type: :shortflag,
          text: word
        }
      else
        {
          type: :unknown,
          text: word
        }
      end
    end
  end

  def self.expand_combined_short_flags(tokens)
    tokens.flat_map do |token|
      if token[:type] == :shortflag
        chars = token[:text].chars
        chars.shift
        chars.map do |char|
          {
            type: :shortflag,
            text: "-#{char}"
          }
        end
      else
        token
      end
    end
  end

  def self.interpret_equal_signs(tokens)
    tokens.map do |token|
      if token[:type] == :longflag && token[:text].include?('=')
        key_value = token[:text].split('=')
        {
          type: :longflag,
          text: key_value[0],
          value: key_value[1]
        }
      else
        token
      end
    end
  end

  def self.assign_arguments(tokens:, manpage:)
    new_tokens = []
    while tokens.length > 0
      token = tokens.shift
      if %i[shortflag longflag].include?(token[:type]) && token[:value].nil?
        takes_argument = manpage&.get_flag(token[:text])&.takes_argument?
        token[:value] = tokens.shift[:text] if takes_argument && tokens.length > 0 && tokens.first[:type] == :unknown
      end
      new_tokens << token
    end
    new_tokens
  end
end
