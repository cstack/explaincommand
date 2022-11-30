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

    context 'when flag is documented as taking argument separated by space' do
      let(:cmd) { 'docker build -t getting-started .' }
      let(:command_name) { Command::Name.new('docker', 'build') }
      let(:manpage) do
        Manpage.new(
          command_name:,
          description: '',
          flags: [
            Flag.new(
              aliases: ['-t'],
              description: 'this flag does something',
              argument_type: :SEPARATED_BY_SPACE
            )
          ],
          positional_arguments: [
            PositionalArgument.new(
              name: 'foo',
              type: PositionalArgument::Type::BASIC
            )
          ]
        )
      end

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
      let(:cmd) { 'command-name -something' }
      let(:command_name) { Command::Name.new('command-name') }
      let(:manpage) do
        Manpage.new(
          command_name:,
          description: '',
          flags: [
            Flag.new(
              aliases: ['-something'],
              description: 'this flag does something',
              argument_type: :NONE
            )
          ],
          positional_arguments: []
        )
      end

      it 'interprets flag correclty' do
        expect(subject.tokens).to eq(
          [
            Command::Token.new(
              type: :command_name,
              text: 'command-name'
            ),
            Command::Token.new(
              type: :flag,
              text: '-something'
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

    context 'when flag uses equal sign' do
      let(:cmd) { 'command-name --key=value' }
      let(:command_name) { Command::Name.new('command-name') }
      let(:manpage) do
        Manpage.new(
          command_name:,
          description: '',
          flags: [
            Flag.new(
              aliases: ['--key'],
              description: 'this flag does something',
              argument_type: Flag::ArgumentType::SEPARATED_BY_EQUAL_SIGN
            )
          ],
          positional_arguments: []
        )
      end

      it 'parses the flag and argument correctly' do
        expect(subject.tokens).to eq(
          [
            Command::Token.new(
              type: :command_name,
              text: 'command-name'
            ),
            Command::Token.new(
              type: :flag,
              text: '--key',
              value: 'value'
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
