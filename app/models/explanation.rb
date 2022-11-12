class Explanation
  attr_reader :annotations, :command_name, :command_description

  def initialize(command_name:, command_description:, annotations:)
    @command_name = command_name
    @command_description = command_description
    @annotations = annotations
  end

  def self.from_manpage(manpage:, command:)
    annotations = []
    command.flags.each do |provided_flag|
      flag_explanation = manpage.get_flag(provided_flag)
      annotations << flag_explanation
    end
    new(command_name: command.name, command_description: manpage.description, annotations:)
  end
end
