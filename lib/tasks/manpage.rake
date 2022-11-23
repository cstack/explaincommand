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
end
