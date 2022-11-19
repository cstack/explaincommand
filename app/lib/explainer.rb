class Explainer
  def self.explain(cmd)
    command_name, subcommand = CommandParser.full_command(cmd)
    manpage = ManpageDirectory.get_manpage(command_name:, subcommand:)
    command = CommandParser.parse(cmd, manpage:)
    Explanation.from_manpage(manpage:, command:)
  end
end
