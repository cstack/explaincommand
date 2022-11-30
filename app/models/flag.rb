# Represents the definition of a flag taken from a manpage
class Flag
  attr_reader :aliases, :description, :argument_type

  def initialize(aliases:, description:, argument_type:)
    @aliases = aliases
    @description = description
    @argument_type = argument_type
  end

  def ==(other)
    return false if other.nil?

    aliases == other.aliases &&
      description == other.description &&
      argument_type == other.argument_type
  end

  def takes_argument_separated_by_space?
    argument_type == ArgumentType::SEPARATED_BY_SPACE
  end

  def takes_argument_separated_by_equal_sign?
    argument_type == ArgumentType::SEPARATED_BY_EQUAL_SIGN
  end

  def self.from_json(json_string)
    from_hash(JSON.parse(json_string))
  end

  def self.from_hash(ruby_hash)
    ruby_hash.transform_keys!(&:to_sym)
    ruby_hash[:argument_type] = ruby_hash[:argument_type].to_sym
    new(**ruby_hash)
  end

  def to_json(*args)
    {
      'aliases' => aliases,
      'description' => description,
      'argument_type' => argument_type
    }.to_json(*args)
  end

  class ArgumentType
    NONE = :NONE
    OPTIONAL_SEPARATED_BY_EQUAL_SIGN = :OPTIONAL_SEPARATED_BY_EQUAL_SIGN
    SEPARATED_BY_EQUAL_SIGN = :SEPARATED_BY_EQUAL_SIGN
    SEPARATED_BY_SPACE = :SEPARATED_BY_SPACE
  end
end
