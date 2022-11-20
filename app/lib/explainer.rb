class Explainer
  def self.explain(cmd)
    command_name = CommandParser.command_name(cmd)
    manpage = ManpageDirectory.get_manpage(command_name)
    command = CommandParser.parse(cmd, manpage:)
    Explanation.from_manpage(manpage:, command:)
  end
end
