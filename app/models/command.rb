class Command
  attr_reader :name, :tokens

  def initialize(name:, tokens:)
    @name = name
    @tokens = tokens.zip(0...tokens.length).map do |token_hash, i|
      Token.new(**token_hash.merge(id: i))
    end
  end

  def ==(other)
    name = other.name &&
           flags == other.flags &&
           arguments == other.arguments
  end

  def command_name_tokens
    tokens.select(&:command_name?)
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
      type = other.type &&
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
end
