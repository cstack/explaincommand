class Explainer
  def self.explain(cmd)
    command_name = CommandParser.command_name(cmd)
    manpage = ManpageDirectory.get_manpage(command_name)
    command = CommandParser.parse(cmd, command_name:, manpage:)

    annotations = []
    annotations << Annotation.new(
      referenced_text: command.display_name,
      text: manpage.description,
      token_ids: command.command_name_tokens.map(&:id)
    )
    remaining_positional_arguments = manpage.positional_arguments
    command.tokens.each do |token|
      case token.type
      when :flag
        flag_explanation = manpage.get_flag(token.text)
        next if flag_explanation.nil?

        annotations << Annotation.new(
          referenced_text: token.original_text,
          text: flag_explanation.description,
          token_ids: [token.id]
        )
      when :positional_argument
        argument_explanation = remaining_positional_arguments[0]
        remaining_positional_arguments.shift unless argument_explanation.repeated?
        next if argument_explanation.nil?

        argument_name = argument_explanation.name

        annotations << Annotation.new(
          referenced_text: token.original_text,
          text: argument_name,
          token_ids: [token.id]
        )
      end
    end
    Explanation.new(command:, annotations:, source_link: manpage.source_link, source_description: manpage.source_description)
  end
end
