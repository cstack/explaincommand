namespace :manpage do
  desc 'Parse a manpage from html into json'
  task :parse, %i[main_command subcommand] => [:environment] do |_task, args|
    main_command = args[:main_command]
    subcommand = args[:subcommand]
    html_string = STDIN.read
    command_name = Command::Name.new(main_command, subcommand)
    manpage = ManpageParser.parse_html_string(html_string:, command_name:)
    File.write(
      "./data/manpages/#{command_name.with_dashes}.json",
      JSON.pretty_generate(manpage)
    )
  end

  desc 'Parse a helppage from text into json'
  task :parse_helppage, %i[main_command subcommand] => [:environment] do |_task, args|
    main_command = args[:main_command]
    subcommand = args[:subcommand]
    helppage_string = STDIN.read
    command_name = Command::Name.new(main_command, subcommand)
    manpage = ManpageParser.parse_helppage_string(helppage_string:, command_name:)
    File.write(
      "./data/manpages/#{command_name.with_dashes}.json",
      JSON.pretty_generate(manpage)
    )
  end
end
