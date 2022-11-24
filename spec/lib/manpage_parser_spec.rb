require 'rails_helper'

describe ManpageParser do
  describe '.parse_html_string' do
    Dir['./spec/fixtures/html_manpages/*'].each do |path|
      filename = path.split('/').last
      command = filename.split('.').first
      command_parts = command.split('-')
      command_name = Command::Name.new(command_parts[0], command_parts[1])
      context filename do
        next unless command == 'curl'

        it 'parses as expected' do
          html_string = File.read(path)
          manpage = described_class.parse_html_string(html_string:, command_name:)
          fixture_path = "./data/manpages/#{command}.json"
          # File.write(fixture_path, JSON.pretty_generate(manpage))
          expected = Manpage.from_json(File.read(fixture_path))
          expect(manpage).to eq(expected)
        end
      end
    end
  end

  describe 'extract_first_usage_from_paragraph' do
    subject { described_class.extract_first_usage_from_paragraph(text:, command_name:) }

    context 'when there is a subcommand' do
      let(:text) { "SYNOPSIS \ngit checkout [-q] [-f] [-m] [<branch>] \ngit checkout [-q] [-f] [-m] --detach [<branch>] \ngit checkout [-q] [-f] [-m] [--detach] <commit> \ngit checkout [-q] [-f] [-m] [[-b|-B|--orphan]\n<new-branch>] [<start-point>] \ngit checkout\n[-f|--ours|--theirs|-m|--conflict=<style>]\n[<tree-ish>] [--] <pathspec>... \ngit checkout\n[-f|--ours|--theirs|-m|--conflict=<style>]\n[<tree-ish>] --pathspec-from-file=<file>\n[--pathspec-file-nul] \ngit checkout (-p|--patch) [<tree-ish>] [--]\n[<pathspec>...]" }
      let(:command_name) { Command::Name.new('git', 'checkout') }

      it 'parses correctly' do
        expect(subject).to eq('git checkout [-q] [-f] [-m] [<branch>]')
      end
    end
  end
end
