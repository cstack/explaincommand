class UsageParser
  def self.extract_positional_arguments_from_usage_pattern(text:, command_name:)
    words = text.split
    num_words_in_command = command_name.num_words
    grouped_words = group_by_brackets(words)
    positional_argument_words = grouped_words.drop(num_words_in_command).reject do |word|
      word.gsub('[', '').start_with?('-') ||
        word.include?('OPTION')
    end
    interpret_ellipses(positional_argument_words)
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

  def self.interpret_ellipses(words)
    result = []
    words.each do |word|
      if word == '...'
        result.last[:repeated] = true
      elsif word.include?('...')
        result << {
          name: word,
          repeated: true
        }
      else
        result << {
          name: word,
          repeated: false
        }
      end
    end
    result
  end
end
