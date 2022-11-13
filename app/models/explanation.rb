class Explanation
  attr_reader :annotations, :command_name, :command_description

  def initialize(command_name:, command_description:, annotations:)
    @command_name = command_name
    @command_description = command_description
    @annotations = annotations
  end

  def self.from_manpage(manpage:, command:)
    annotations = []
    annotations << Annotation.new(
      referenced_text: command.name,
      text: manpage.description
    )
    command.flags.each do |provided_flag|
      if provided_flag.is_a?(Array)
        provided_flag = provided_flag[0]
        argument = provided_flag[1]
        referenced_text = "#{provided_flag} #{argument}"
      else
        referenced_text = provided_flag
      end
      flag_explanation = manpage.get_flag(provided_flag)
      annotations << Annotation.new(
        referenced_text:,
        text: flag_explanation.description
      )
    end
    new(command_name: command.name, command_description: manpage.description, annotations:)
  end
end
