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
  end
end
