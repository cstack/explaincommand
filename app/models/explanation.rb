class Explanation
  attr_reader :annotations, :command_description, :command

  def initialize(command:, command_description:, annotations:)
    @command = command
    @command_description = command_description
    @annotations = annotations
  end

  def self.from_manpage(manpage:, command:)
    annotations = []
    annotations << Annotation.new(
      referenced_text: command.display_name,
      text: manpage.description,
      token_ids: command.command_name_tokens.map(&:id),
      source_link: manpage.source_link,
      source_description: manpage.source_description
    )
    remaining_positional_arguments = manpage.positional_arguments
    command.tokens.each do |token|
      if token.type == :flag
        flag_explanation = manpage.get_flag(token.text)
        next if flag_explanation.nil?

        annotations << Annotation.new(
          referenced_text: token.original_text,
          text: flag_explanation.description,
          token_ids: [token.id]
        )
      elsif token.type == :positional_argument
        argument_explanation = remaining_positional_arguments[0]
        remaining_positional_arguments.shift unless argument_explanation[:repeated]
        next if argument_explanation.nil?

        argument_name = argument_explanation[:name]

        annotations << Annotation.new(
          referenced_text: token.original_text,
          text: argument_name,
          token_ids: [token.id]
        )
      end
    end
    new(command:, command_description: manpage.description, annotations:)
  end
end
