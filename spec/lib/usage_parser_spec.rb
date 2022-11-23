require 'rails_helper'

describe UsageParser do
  describe 'extract_positional_arguments_from_usage_pattern' do
    subject { described_class.extract_positional_arguments_from_usage_pattern(text:, command_name:) }

    context 'chmod' do
      let(:text) { 'chmod [-fhv] [-R [-H | -L | -P]] mode file ...' }
      let(:command_name) { Command::Name.new('chmod') }

      it 'parses correctly' do
        expect(subject).to eq(
          [
            {
              name: 'mode',
              repeated: false
            },
            {
              name: 'file',
              repeated: true
            }
          ]
        )
      end
    end

    context 'find' do
      let(:text) { 'find [-H | -L | -P] [-EXdsx] [-f path] path ... [expression]' }
      let(:command_name) { Command::Name.new('find') }

      it 'parses correctly' do
        expect(subject).to eq(
          [
            {
              name: 'path',
              repeated: true
            },
            {
              name: '[expression]',
              repeated: false
            }
          ]
        )
      end
    end

    context 'when there is a subcommand' do
      let(:text) do
        'git checkout [-q] [-f] [-m] [<branch>]'
      end
      let(:command_name) { Command::Name.new('git', 'add') }

      it 'parses correctly' do
        expect(subject).to eq(
          [
            {
              name: '[<branch>]',
              repeated: false
            }
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
            {
              name: '[file ...]',
              repeated: true
            }
          ]
        )
      end
    end

    context 'when there is an argument called OPTIONS' do
      let(:text) do
        'docker attach [OPTIONS] CONTAINER'
      end
      let(:command_name) { Command::Name.new('docker', 'attach') }

      it 'parses correctly' do
        expect(subject).to eq(
          [
            {
              name: 'CONTAINER',
              repeated: false
            }
          ]
        )
      end
    end
  end
end
