class Command
  attr_reader :arguments, :flags, :name

  def initialize(name:, flags:, arguments:)
    @name = name
    @flags = flags
    @arguments = arguments
  end

  def ==(other)
    name = other.name &&
           flags == other.flags &&
           arguments == other.arguments
  end
end
