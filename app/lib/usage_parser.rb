class UsageParser
  def self.break_usage_pattern_into_words(text)
    # Some manpages have nonbreaking spaces
    normalized = text.gsub(/ /, ' ')
    words = normalized.split
    group_by_brackets(words)
  end

  def self.extract_positional_arguments_from_usage_pattern(text:, command_name:)
    words = break_usage_pattern_into_words(text)
    num_words_in_command = command_name.num_words
    positional_argument_words = words.drop(num_words_in_command).reject do |word|
      word_is_flag?(word) ||
        word.include?('OPTION') ||
        word.include?('Experimental')
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
    args = interpret_vertical_bars(args)
    args.map do |arg|
      PositionalArgument.new(**arg)
    end
  end

  def self.word_is_flag?(word)
    return false if word == '-'

    word.gsub('[', '').start_with?('-')
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

  def self.interpret_vertical_bars(args)
    result = []
    while args.length > 0
      arg = args.shift
      if arg[:name] == '|'
        result.last[:type] = PositionalArgument::Type::ONE_OF_SEVERAL
        result.last[:name] += " | #{args.shift[:name]}"
      else
        result << arg
      end
    end
    result
  end
end
