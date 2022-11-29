namespace :manpage do
  desc 'Download a manpage from manpages.ubuntu.com, parse it and save it into repo'
  task :import, %i[main_command subcommand] => [:environment] do |_task, args|
    main_command = args.fetch(:main_command)
    subcommand = args.fetch(:subcommand, nil)
    command_name = Command::Name.new(main_command, subcommand)

    puts 'Fetching manpage...'
    `curl https://manpages.ubuntu.com/manpages.gz/kinetic/man1/#{command_name.with_dashes}.1.gz --output /tmp/#{command_name.with_dashes}.1.gz`
    puts 'Unzipping...'
    `gzip -d /tmp/#{command_name.with_dashes}.1.gz`
    puts 'Converting to html...'
    `mandoc -T html /tmp/#{command_name.with_dashes}.1 > /tmp/#{command_name.with_dashes}.html`
    puts 'Parsing html...'
    html_string = File.read("/tmp/#{command_name.with_dashes}.html")
    manpage = ManpageParser.parse_html_string(html_string:, command_name:)
    puts 'Saving...'
    File.write(
      "./data/manpages/#{command_name.with_dashes}.json",
      JSON.pretty_generate(manpage)
    )
  end
end
