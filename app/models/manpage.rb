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
    ruby_hash = JSON.parse(json_string).transform_keys(&:to_sym)
    ruby_hash[:flags] = ruby_hash[:flags].map do |flag_hash|
      Flag.from_hash(flag_hash)
    end
    new(**ruby_hash)
  end

  def to_json(*args)
    {
      'description' => description,
      'flags' => flags
    }.to_json(*args)
  end

  def get_flag(string)
    flags.find do |flag|
      flag.aliases.include?(string)
    end
  end

  def source_link
    nil
  end

  def source_description
    nil
  end

  class UnknownCommand < Manpage
    def initialize
      super(description: 'Unknown command', flags: [])
    end

    def source_link
      'https://github.com/cstack/explaincommand#import-a-man-page'
    end

    def source_description
      'Contribute missing documentation'
    end
  end
end
