class PositionalArgument
  attr_reader :name, :type

  def initialize(name:, type:)
    @name = name
    @type = type
  end

  def ==(other)
    name == other.name &&
      type == other.type
  end

  def to_hash
    {
      name:,
      type:
    }
  end

  def self.from_hash(hash)
    args = hash.transform_keys(&:to_sym)
    args[:type] = args[:type].to_sym
    new(**args)
  end

  def repeated?
    type == Type::REPEATED
  end

  class Type
    BASIC = :BASIC
    REPEATED = :REPEATED
    COMMA_SEPARTED = :COMMA_SEPARTED
  end
end
