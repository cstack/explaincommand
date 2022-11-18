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
    command.tokens.each do |token|
      next unless token.type == :flag

      flag_explanation = manpage.get_flag(token.text)
      next if flag_explanation.nil?

      annotations << Annotation.new(
        referenced_text: token.original_text,
        text: flag_explanation.description,
        token_ids: [token.id]
      )
    end
    new(command:, command_description: manpage.description, annotations:)
  end
end
