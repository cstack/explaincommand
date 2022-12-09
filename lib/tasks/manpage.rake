# rubocop:disable Metrics/BlockLength
namespace :manpage do
  desc 'Download a manpage from manpages.ubuntu.com, parse it and save it into repo'
  task :import, %i[main_command subcommand] => [:environment] do |_task, args|
    main_command = args.fetch(:main_command)
    subcommand = args.fetch(:subcommand, nil)
    command_name = Command::Name.new(main_command, subcommand)

    puts 'Fetching manpage...'
    url = "https://manpages.ubuntu.com/manpages.gz/kinetic/man1/#{command_name.with_dashes}.1.gz"
    success = system("curl -fL #{url} --output /tmp/#{command_name.with_dashes}.1.gz")
    raise "Failed to download #{url}" unless success

    puts 'Unzipping...'
    `yes | gzip -d /tmp/#{command_name.with_dashes}.1.gz`
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

  desc 'Download a manpage from manpages.ubuntu.com, parse it and save it into repo'
  task :reimport_all, %i[] => [:environment] do
    Dir['./data/manpages/*.json'].each do |path|
      puts "Reimporting #{path}"
      raw_command_name = File.basename(path, '.*')
      parts = raw_command_name.split('-')
      command_name = if parts.length == 1
                       Command::Name.new(raw_command_name)
                     else
                       Command::Name.new(parts[0], parts.drop(1).join('-'))
                     end

      puts 'Fetching manpage...'
      url = "https://manpages.ubuntu.com/manpages.gz/kinetic/man1/#{command_name.with_dashes}.1.gz"
      success = system("curl -fL #{url} --output /tmp/#{command_name.with_dashes}.1.gz")
      raise "Failed to download #{url}" unless success

      puts 'Unzipping...'
      `yes | gzip -d /tmp/#{command_name.with_dashes}.1.gz`
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
end
# rubocop:enable Metrics/BlockLength
