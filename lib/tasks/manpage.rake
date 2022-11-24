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

  desc 'Download a manpage from manpages.ubuntu.com, parse it and save it into repo'
  task :import, %i[main_command subcommand] => [:environment] do |_task, args|
    main_command = args.fetch(:main_command)
    subcommand = args.fetch(:subcommand, nil)
    command_name = Command::Name.new(main_command, subcommand)

    `curl https://manpages.ubuntu.com/manpages.gz/kinetic/man1/#{command_name.with_dashes}.1.gz --output /tmp/#{command_name.with_dashes}.1.gz`
    `gzip -d /tmp/#{command_name.with_dashes}.1.gz`
    `mandoc -T html /tmp/#{command_name.with_dashes}.1 > /tmp/#{command_name.with_dashes}.html`
    html_string = File.read("/tmp/#{command_name.with_dashes}.html")
    manpage = ManpageParser.parse_html_string(html_string:, command_name:)
    File.write(
      "./data/manpages/#{command_name.with_dashes}.json",
      JSON.pretty_generate(manpage)
    )
  end
end
