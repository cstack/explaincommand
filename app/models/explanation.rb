class Explanation
  attr_reader :annotations, :command_description

  def initialize(command:, command_description:, annotations:)
    @command = command
    @command_description = command_description
    @annotations = annotations
  end

  def command_name
    @command.name
  end

  def command_spans
    @command.tokens.map(&:original_text)
  end

  def self.from_manpage(manpage:, command:)
    annotations = []
    annotations << Annotation.new(
      referenced_text: command.name,
      text: manpage.description
    )
    command.tokens.each do |token|
      next unless token.type == :flag

      flag_explanation = manpage.get_flag(token.text)
      annotations << Annotation.new(
        referenced_text: token.original_text,
        text: flag_explanation.description
      )
    end
    new(command:, command_description: manpage.description, annotations:)
  end
end
