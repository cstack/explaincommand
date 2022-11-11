class Explanation
  attr_reader :annotations, :command

  def initialize(command:, annotations:)
    @command = command
    @annotations = annotations
  end

  def self.from_manpage(manpage:, parsed_arguments:)
    command = parsed_arguments[:command]
    annotations = []
    parsed_arguments[:flags].each do |provided_flag|
      flag_explanation = manpage[:flags].find do |man_flag|
        man_flag[0] == provided_flag
      end
      annotations << flag_explanation
    end
    new(command: command, annotations: annotations)
  end
end