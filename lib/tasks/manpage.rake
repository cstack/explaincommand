# rubocop:disable Metrics/BlockLength
namespace :manpage do
  desc 'Parse a manpage from html into json'
  task :parse, %i[filepath main_command subcommand] => [:environment] do |_task, args|
    filepath = args.fetch(:filepath)
    main_command = args.fetch(:main_command)
    subcommand = args.fetch(:subcommand, nil)
    html_string = File.read(filepath)
    command_name = Command::Name.new(main_command, subcommand)
    manpage = ManpageParser.parse_html_string(html_string:, command_name:)
    File.write(
      "./data/manpages/#{command_name.with_dashes}.json",
      JSON.pretty_generate(manpage)
    )
  end

  desc 'Parse a helppage from text into json'
  task :parse_helppage, %i[filepath main_command subcommand] => [:environment] do |_task, args|
    filepath = args.fetch(:filepath)
    main_command = args.fetch(:main_command)
    subcommand = args.fetch(:subcommand, nil)
    helppage_string = File.read(filepath)
    command_name = Command::Name.new(main_command, subcommand)
    manpage = ManpageParser.parse_helppage_string(helppage_string:, command_name:)
    File.write(
      "./data/manpages/#{command_name.with_dashes}.json",
      JSON.pretty_generate(manpage)
    )
  end
end
# rubocop:enable Metrics/BlockLength
