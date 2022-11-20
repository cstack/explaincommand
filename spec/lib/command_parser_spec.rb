require 'rails_helper'

describe CommandParser do
  describe '.parse' do
    subject { described_class.parse(cmd, command_name:, manpage:) }

    let(:manpage) { nil }

    context 'when flag takes argument, but no manpage is provided' do
      let(:cmd) { 'docker build -t getting-started .' }
      let(:command_name) { Command::Name.new('docker', 'build') }
      let(:manpage) { nil }

      it 'does not bind argument' do
        expect(subject.tokens).to eq(
          [
            Command::Token.new(
              type: :command_name,
              text: 'docker'
            ),
            Command::Token.new(
              type: :command_name,
              text: 'build'
            ),
            Command::Token.new(
              type: :flag,
              text: '-t'
            ),
            Command::Token.new(
              type: :unknown,
              text: 'getting-started'
            ),
            Command::Token.new(
              type: :unknown,
              text: '.'
            )
          ]
        )
      end
    end

    context 'when flag takes argument and manpage is provided' do
      let(:cmd) { 'docker build -t getting-started .' }
      let(:command_name) { Command::Name.new('docker', 'build') }
      let(:manpage) { ManpageDirectory.get_manpage(command_name) }

      it 'binds argument to flag' do
        expect(subject.tokens).to eq(
          [
            Command::Token.new(
              type: :command_name,
              text: 'docker'
            ),
            Command::Token.new(
              type: :command_name,
              text: 'build'
            ),
            Command::Token.new(
              type: :flag,
              text: '-t',
              value: 'getting-started'
            ),
            Command::Token.new(
              type: :positional_argument,
              text: '.'
            )
          ]
        )
      end
    end

    context 'when documented single-dash flag has multi-character name' do
      let(:cmd) { 'find . -type f -print0' }
      let(:command_name) { Command::Name.new('find') }
      let(:manpage) { ManpageDirectory.get_manpage(command_name) }

      it 'interprets flag correclty' do
        expect(subject.tokens).to eq(
          [
            Command::Token.new(
              type: :command_name,
              text: 'find'
            ),
            Command::Token.new(
              type: :positional_argument,
              text: '.'
            ),
            Command::Token.new(
              type: :flag,
              text: '-type',
              value: 'f'
            ),
            Command::Token.new(
              type: :flag,
              text: '-print0'
            )
          ]
        )
      end
    end

    context 'when command uses documented positional arguments' do
      let(:cmd) { 'chmod 600 id_rsa_gh_deploy' }
      let(:command_name) { Command::Name.new('chmod') }
      let(:manpage) { ManpageDirectory.get_manpage(command_name) }

      it 'labels positional arguments' do
        expect(subject.tokens).to eq(
          [
            Command::Token.new(
              type: :command_name,
              text: 'chmod'
            ),
            Command::Token.new(
              type: :positional_argument,
              text: '600'
            ),
            Command::Token.new(
              type: :positional_argument,
              text: 'id_rsa_gh_deploy'
            )
          ]
        )
      end
    end
  end

  describe '.command_name' do
    subject { described_class.command_name(string) }

    context 'existing command with no subcommand' do
      let(:string) { 'ls .' }

      it 'parses correctly' do
        expect(subject).to eq(Command::Name.new('ls'))
      end
    end

    context 'missing command' do
      let(:string) { 'command-does-not-exist' }

      it 'parses correctly' do
        expect(subject).to eq(Command::Name.new('command-does-not-exist'))
      end
    end

    context 'existing command with subcommand' do
      let(:string) { 'git add .' }

      it 'parses correctly' do
        expect(subject).to eq(Command::Name.new('git', 'add'))
      end
    end
  end
end
