class Command
  attr_reader :name

  def initialize(name:, tokens:)
    @name = name
    @tokens = tokens
  end

  def ==(other)
    name = other.name &&
           flags == other.flags &&
           arguments == other.arguments
  end

  def flags
    @tokens.select do |token|
      %i[shortflag longflag].include?(token[:type])
    end.map do |token|
      if token[:value].nil?
        token[:text]
      else
        [token[:text], token[:value]]
      end
    end
  end

  def arguments
    @tokens.select do |token|
      token[:type] == :unknown
    end.map do |token|
      token[:text]
    end
  end
end
