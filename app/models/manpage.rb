class Manpage
  attr_reader :command_name, :flags, :description, :positional_arguments

  def initialize(command_name:, description:, flags:, positional_arguments:)
    @command_name = command_name
    @description = description
    @flags = flags
    @positional_arguments = positional_arguments
  end

  def ==(other)
    description == other.description &&
      flags == other.flags &&
      positional_arguments == other.positional_arguments
  end

  def self.from_json(json_string)
    ruby_hash = JSON.parse(json_string).transform_keys(&:to_sym)
    main_command = ruby_hash[:command_name]['main_command']
    subcommand = ruby_hash[:command_name]['subcommand']
    ruby_hash[:command_name] = Command::Name.new(main_command, subcommand)
    ruby_hash[:flags] = ruby_hash[:flags].map do |flag_hash|
      Flag.from_hash(flag_hash)
    end
    ruby_hash[:positional_arguments] = ruby_hash[:positional_arguments].map do |arg|
      PositionalArgument.from_hash(arg)
    end
    new(**ruby_hash)
  end

  def to_json(*args)
    {
      'command_name' => command_name.to_hash,
      'description' => description,
      'flags' => flags,
      'positional_arguments' => positional_arguments.map(&:to_hash)
    }.to_json(*args)
  end

  def get_flag(string)
    flags.find do |flag|
      flag.aliases.include?(string)
    end
  end

  def source_link
    "https://manpages.ubuntu.com/manpages/kinetic/en/man1/#{command_name.with_dashes}.1.html"
  end

  def source_description
    'Full documentation'
  end

  class UnknownCommand < Manpage
    def initialize(command_name:)
      super(command_name:, description: 'Unknown command', flags: [], positional_arguments: [])
    end

    def source_link
      'https://github.com/cstack/explaincommand#import-a-man-page'
    end

    def source_description
      'Contribute missing documentation'
    end
  end
end
