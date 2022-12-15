require 'rails_helper'

describe ManpageParser do
  describe '.extract_first_usage' do
    subject { described_class.extract_first_usage(text:, command_name:) }

    context 'only one usage' do
      let(:text) do
        'curl [options / URLs]'
      end
      let(:command_name) { Command::Name.new('curl') }

      it 'returns the one usage' do
        expect(subject).to eq('curl [options / URLs]')
      end
    end

    context 'multiple usages' do
      let(:text) do
        'chmod [OPTION]... MODE[,MODE]... FILE... chmod [OPTION]... OCTAL-MODE FILE... chmod [OPTION]... ' \
          '--reference=RFILE FILE...'
      end
      let(:command_name) { Command::Name.new('chmod') }

      it 'returns the first usage' do
        expect(subject).to eq('chmod [OPTION]... MODE[,MODE]... FILE...')
      end
    end

    context 'when there is a subcommand' do
      let(:text) do
        'git checkout [-q] [-f] [-m] [<branch>] git checkout [-q] [-f] [-m] --detach [<branch>] ' \
          'git checkout [-q] [-f] [-m] [--detach] <commit> ' \
          'git checkout [-q] [-f] [-m] [[-b|-B|--orphan] <new-branch>] [<start-point>] ' \
          'git checkout [-f|--ours|--theirs|-m|--conflict=<style>] [<tree-ish>] [--] <pathspec>... ' \
          'git checkout [-f|--ours|--theirs|-m|--conflict=<style>] [<tree-ish>] --pathspec-from-file=<file> ' \
          '[--pathspec-file-nul] ' \
          'git checkout (-p|--patch) [<tree-ish>] [--] [<pathspec>...]'
      end
      let(:command_name) { Command::Name.new('git', 'checkout') }

      it 'parses correctly' do
        expect(subject).to eq('git checkout [-q] [-f] [-m] [<branch>]')
      end
    end

    context 'when a positional argument has same name as command' do
      let(:text) do
        'file [-bcdEhiklLNnprsSvzZ0] [--apple] [--exclude-quiet] [--extension] [--mime-encoding] [--mime-type] ' \
          '[-e testname] [-F separator] [-f namefile] [-m magicfiles] [-P name=value] file ... ' \
          'file -C [-m magicfiles] file [--help]'
      end
      let(:command_name) { Command::Name.new('file') }

      it 'includes the positional argument' do
        expect(subject).to eq(
          'file [-bcdEhiklLNnprsSvzZ0] [--apple] [--exclude-quiet] [--extension] [--mime-encoding] [--mime-type] ' \
          '[-e testname] [-F separator] [-f namefile] [-m magicfiles] [-P name=value] file ...'
        )
      end
    end
  end

  describe '.parse_html_string' do
    Dir['./spec/fixtures/html_manpages/*'].each do |path|
      filename = path.split('/').last
      command = filename.split('.').first
      command_parts = command.split('-')
      command_name = Command::Name.new(command_parts[0], command_parts[1])
      context filename do
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
end
