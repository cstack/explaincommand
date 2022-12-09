require 'rails_helper'

describe UsageParser do
  describe 'extract_positional_arguments_from_usage_pattern' do
    subject { described_class.extract_positional_arguments_from_usage_pattern(text:, command_name:) }

    context 'when there are ellipses detached from an argument' do
      let(:text) { 'chmod [-fhv] [-R [-H | -L | -P]] mode file ...' }
      let(:command_name) { Command::Name.new('chmod') }

      it 'treats the argument as repated' do
        expect(subject).to eq(
          [
            PositionalArgument.new(
              name: 'mode',
              type: PositionalArgument::Type::BASIC
            ),
            PositionalArgument.new(
              name: 'file',
              type: PositionalArgument::Type::REPEATED
            )
          ]
        )
      end
    end

    context 'when there is a subcommand' do
      let(:text) do
        'git checkout [-q] [-f] [-m] [<branch>]'
      end
      let(:command_name) { Command::Name.new('git', 'checkout') }

      it 'does not treat the subcommand as a positional argument' do
        expect(subject).to eq(
          [
            PositionalArgument.new(
              name: '[<branch>]',
              type: PositionalArgument::Type::BASIC
            )
          ]
        )
      end
    end

    context 'when elipses appear inside brackets' do
      let(:text) do
        'ls [-@ABCFGHILOPRSTUWabcdefghiklmnopqrstuvwxy1%,] [--color=when] [-D format] [file ...]'
      end
      let(:command_name) { Command::Name.new('ls') }

      it 'parses correctly' do
        expect(subject).to eq(
          [
            PositionalArgument.new(
              name: 'file',
              type: PositionalArgument::Type::REPEATED
            )
          ]
        )
      end
    end

    context 'when there is an argument called OPTIONS' do
      let(:text) do
        'docker attach [OPTIONS] CONTAINER'
      end
      let(:command_name) { Command::Name.new('docker', 'attach') }

      it 'does not treat OPTIONS as a positional argument' do
        expect(subject).to eq(
          [
            PositionalArgument.new(
              name: 'CONTAINER',
              type: PositionalArgument::Type::BASIC
            )
          ]
        )
      end
    end

    context 'when there is an argument called OPTION' do
      let(:text) do
        'ls [OPTION]... [FILE]...'
      end
      let(:command_name) { Command::Name.new('ls') }

      it 'does not treat OPTION as a positional argument' do
        expect(subject).to eq(
          [
            PositionalArgument.new(
              name: 'FILE',
              type: PositionalArgument::Type::REPEATED
            )
          ]
        )
      end
    end

    context 'when there is an argument called [option]...' do
      let(:text) do
        'wget [option]... [URL]...'
      end
      let(:command_name) { Command::Name.new('wget') }

      it 'does not treat [option]... as a positional argument' do
        expect(subject).to eq(
          [
            PositionalArgument.new(
              name: 'URL',
              type: PositionalArgument::Type::REPEATED
            )
          ]
        )
      end
    end

    context 'when there is an argument called [options / URLs]' do
      let(:text) do
        'curl [options / URLs]'
      end
      let(:command_name) { Command::Name.new('curl') }

      it 'treats [options / URLs] as a positional argument' do
        expect(subject).to eq(
          [
            PositionalArgument.new(
              name: '[options / URLs]',
              type: PositionalArgument::Type::BASIC
            )
          ]
        )
      end
    end

    context 'when a positional argument is comma-separated' do
      let(:text) do
        'chmod [OPTION]... MODE[,MODE]... FILE...'
      end
      let(:command_name) { Command::Name.new('chmod') }

      it 'parses correctly' do
        expect(subject).to eq(
          [
            PositionalArgument.new(
              name: 'MODE',
              type: PositionalArgument::Type::COMMA_SEPARTED
            ),
            PositionalArgument.new(
              name: 'FILE',
              type: PositionalArgument::Type::REPEATED
            )
          ]
        )
      end
    end

    context 'when a flag is labeled experimental' do
      let(:text) do
        'docker build [-squash] Experimental'
      end
      let(:command_name) { Command::Name.new('docker', 'build') }

      it 'parses correctly' do
        expect(subject).to eq(
          []
        )
      end
    end

    context 'when several positional arguments are mutually exclusive' do
      let(:text) do
        'docker build [--ulimit[=[]]] PATH | URL | -'
      end
      let(:command_name) { Command::Name.new('docker', 'build') }

      it 'parses correctly' do
        expect(subject).to eq(
          [
            PositionalArgument.new(
              name: 'PATH | URL | -',
              type: PositionalArgument::Type::ONE_OF_SEVERAL
            )
          ]
        )
      end
    end
  end

  describe '.break_usage_pattern_into_words' do
    subject { described_class.break_usage_pattern_into_words(text) }

    context 'when there is a nonbreaking space' do
      let(:text) { 'file [-P name=value] file ...' }

      it 'treats nonbreaking spaces as spaces' do
        expect(subject).to eq(['file', '[-P name=value]', 'file', '...'])
      end
    end
  end
end
