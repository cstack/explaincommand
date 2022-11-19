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
    tokens = assign_arguments_to_flags(tokens:, manpage:)
    tokens = label_documented_positional_arguments(tokens:, manpage:)
    Command.new(
      tokens:
    )
  end

  def self.token_string_representation(tokens)
    tokens.map do |token|
      "(#{token[:type]}:#{token[:text]})"
    end.join(' ')
  end

  def self.label_command_name(tokens)
    tokens.first[:type] = :command_name
    command_name = tokens.first[:text]
    if tokens.length > 1
      possible_subcommand = tokens.second[:text]
      tokens.second[:type] = :command_name if ManpageDirectory.exists?(command_name:, subcommand: possible_subcommand)
    end
    tokens
  end

  def self.full_command(string)
    words = string.split
    command_name = words.shift
    if words.length > 0
      possible_subcommand = words.first
      subcommand = possible_subcommand if ManpageDirectory.exists?(command_name:, subcommand: possible_subcommand)
    end
    [command_name, subcommand]
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

  def self.assign_arguments_to_flags(tokens:, manpage:)
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

  def self.label_documented_positional_arguments(tokens:, manpage:)
    return tokens if manpage.nil?

    num_positional_arguments = manpage.positional_arguments.length
    has_repeated_arg = manpage.positional_arguments.any? { |arg| arg[:repeated] }
    tokens.map do |token|
      next token unless token[:type] == :unknown
      next token unless num_positional_arguments > 0 || has_repeated_arg

      num_positional_arguments -= 1
      {
        type: :positional_argument,
        text: token[:text]
      }
    end
  end
end
