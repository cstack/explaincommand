class Manpage
  attr_reader :flags, :name

  def initialize(name:, flags:)
    @name = name
    @flags = flags
  end

  def ==(other)
    name == other.name &&
      flags == other.flags
  end

  def self.from_json(json_string)
    new(**JSON.parse(json_string).transform_keys(&:to_sym))
  end
end
