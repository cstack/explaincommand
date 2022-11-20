class Explanation
  attr_reader :annotations, :command

  def initialize(command:, annotations:)
    @command = command
    @annotations = annotations
  end
end
