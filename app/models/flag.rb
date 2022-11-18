class Flag
  attr_reader :aliases, :description, :takes_argument

  def initialize(aliases:, description:, takes_argument:)
    @aliases = aliases
    @description = description
    @takes_argument = takes_argument
  end

  def takes_argument?
    takes_argument
  end

  def ==(other)
    return false if other.nil?

    aliases == other.aliases &&
      description == other.description &&
      takes_argument == other.takes_argument
  end

  def self.from_json(json_string)
    from_hash(JSON.parse(json_string))
  end

  def self.from_hash(ruby_hash)
    new(**ruby_hash.transform_keys(&:to_sym))
  end

  def to_json(*args)
    {
      'aliases' => aliases,
      'description' => description,
      'takes_argument' => takes_argument
    }.to_json(*args)
  end
end
