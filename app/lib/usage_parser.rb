class UsageParser
  def self.extract_positional_arguments_from_usage_pattern(text:, command_name:)
    words = text.split
    num_words_in_command = command_name.num_words
    grouped_words = group_by_brackets(words)
    positional_argument_words = grouped_words.drop(num_words_in_command).reject do |word|
      word.gsub('[', '').start_with?('-') ||
        word.include?('OPTION')
    end
    args = positional_argument_words.map do |word|
      {
        name: word,
        type: PositionalArgument::Type::BASIC
      }
    end
    args = identify_comma_separated(args)
    args = identify_repeated(args)
    args = interpret_ellipses(args)
    args.map do |arg|
      PositionalArgument.new(**arg)
    end
  end

  def self.group_by_brackets(words)
    result = []
    while words.length > 0
      word = words.shift
      word = "#{word} #{words.shift}" while word.count('[') > word.count(']') && words.length > 0
      result << word
    end
    result
  end

  def self.interpret_ellipses(args)
    result = []
    args.each do |arg|
      if arg[:name] == '...'
        result.last[:type] = PositionalArgument::Type::REPEATED
      else
        result << arg
      end
    end
    result
  end

  def self.identify_comma_separated(args)
    args.each do |arg|
      match_result = arg[:name].match(/(.+)\[,.+\]\.\.\./)
      if match_result
        arg[:type] = PositionalArgument::Type::COMMA_SEPARTED
        arg[:name] = match_result[1]
      end
    end
    args
  end

  def self.identify_repeated(args)
    args.each do |arg|
      match_result = arg[:name].match(/(.+)\.\.\./)
      if match_result && arg[:type] == PositionalArgument::Type::BASIC
        arg[:type] = PositionalArgument::Type::REPEATED
        arg[:name] = match_result[1].gsub('[', '').gsub(']', '').strip
      end
    end
    args
  end

  def self.as_basic(word)
    PositionalArgument.new(
      name: word,
      type: PositionalArgument::Type::BASIC
    )
  end
end
