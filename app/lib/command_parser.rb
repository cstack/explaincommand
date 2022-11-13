class CommandParser
  def self.parse(cmd, manpage: nil)
    tokens = cmd.split.map do |word|
      {
        type: :unknown,
        text: word
      }
    end
    tokens = label_command_name(tokens)
    tokens = label_documented_flags(tokens:, manpage:)
    tokens = expand_combined_short_flags(tokens)
    tokens = label_all_remaining_flags(tokens)
    tokens = interpret_equal_signs(tokens)
    tokens = assign_arguments(tokens:, manpage:)
    command_name = tokens.select do |token|
      token[:type] == :command_name
    end.map do |token|
      token[:text]
    end.join('-')
    Command.new(
      name: command_name,
      tokens:
    )
  end

  def self.token_string_representation(tokens)
    tokens.map do |token|
      "(#{token[:type]}:#{token[:text]})"
    end.join(' ')
  end

  def self.label_command_name(tokens)
    num_words = 1
    candidate_command_name = tokens.first[:text]
    tokens.drop(1).each_with_index do |token, i|
      candidate_command_name += '-' + token[:text]
      num_words = i + 2 if ManpageDirectory.manpage_exists?(candidate_command_name)
    end
    tokens.first(num_words).each do |token|
      token[:type] = :command_name
    end
    tokens
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

  def self.label_all_remaining_flags(tokens)
    tokens.each do |token|
      token[:type] = :flag if token[:type] == :unknown && token[:text].start_with?('-')
    end
    tokens
  end

  def self.label_documented_flags(tokens:, manpage:)
    return tokens if manpage.nil?

    documented_flags = Set.new(manpage.flags.flat_map(&:aliases))
    tokens.map do |token|
      if token[:type] == :unknown && documented_flags.include?(token[:text])
        {
          type: :flag,
          text: token[:text]
        }
      else
        token
      end
    end
  end

  def self.expand_combined_short_flags(tokens)
    tokens.flat_map do |token|
      if token[:type] == :unknown && token[:text].match?(/^-[a-zA-Z0-9]/)
        chars = token[:text].chars
        chars.shift
        chars.map do |char|
          {
            type: :flag,
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
      if token[:type] == :flag && token[:text].include?('=')
        key_value = token[:text].split('=')
        {
          type: :flag,
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
      if token[:type] == :flag && token[:value].nil?
        takes_argument = manpage&.get_flag(token[:text])&.takes_argument?
        token[:value] = tokens.shift[:text] if takes_argument && tokens.length > 0 && tokens.first[:type] == :unknown
      end
      new_tokens << token
    end
    new_tokens
  end
end
