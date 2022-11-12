class Manpage
  attr_reader :flags, :description

  def initialize(description:, flags:)
    @description = description
    @flags = flags
  end

  def ==(other)
    description == other.description &&
      flags == other.flags
  end

  def self.from_json(json_string)
    new(**JSON.parse(json_string).transform_keys(&:to_sym))
  end

  def to_json(*a)
    {
      'description' => description,
      'flags' => flags
    }.to_json(*a)
  end
end
