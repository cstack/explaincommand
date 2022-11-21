class Command
  attr_reader :command_name, :tokens

  def initialize(command_name:, tokens:)
    @command_name = command_name
    @tokens = tokens.zip(0...tokens.length).map do |token_hash, i|
      Token.new(**token_hash.merge(id: i))
    end
  end

  def ==(other)
    name == other.name &&
      flags == other.flags &&
      arguments == other.arguments
  end

  def command_name_tokens
    tokens.select do |token|
      token.type == :command_name
    end
  end

  def display_name
    command_name_tokens.map(&:text).join(' ')
  end

  class Token
    attr_reader :id, :text, :type

    def initialize(type:, text:, value: nil, id: nil)
      @id = id
      @type = type
      @text = text
      @value = value
    end

    def ==(other)
      type == other.type &&
        original_text == other.original_text
    end

    def original_text
      if @type == :flag && !@value.nil?
        "#{text} #{@value}"
      else
        text
      end
    end

    def command_name?
      type == :command_name
    end
  end

  class Name
    attr_reader :main_command, :subcommand

    def initialize(main_command, subcommand = nil)
      @main_command = main_command
      @subcommand = subcommand
    end

    def ==(other)
      main_command == other.main_command &&
        subcommand == other.subcommand
    end

    def to_hash
      {
        main_command:,
        subcommand:
      }
    end

    def with_dashes
      if subcommand.nil?
        main_command
      else
        "#{main_command}-#{subcommand}"
      end
    end

    def num_words
      if subcommand.nil?
        1
      else
        2
      end
    end
  end
end
