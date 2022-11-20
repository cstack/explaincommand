class Explanation
  attr_reader :annotations, :command, :source_link, :source_description

  def initialize(command:, annotations:, source_link:, source_description:)
    @command = command
    @annotations = annotations
    @source_link = source_link
    @source_description = source_description
  end

  def to_json(*args)
    {
      'command' => command,
      'annotations' => annotations,
      'source_link' => source_link
    }.to_json(*args)
  end
end
