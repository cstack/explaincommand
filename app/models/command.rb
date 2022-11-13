class Command
  attr_reader :name, :tokens

  def initialize(name:, tokens:)
    @name = name
    @tokens = tokens.map { |token_hash| Token.new(**token_hash) }
  end

  def ==(other)
    name = other.name &&
           flags == other.flags &&
           arguments == other.arguments
  end

  class Token
    attr_reader :text, :type

    def initialize(type:, text:, value: nil)
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
  end
end
