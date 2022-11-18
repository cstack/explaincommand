require 'rails_helper'

describe CommandParser do
  subject { described_class.parse(cmd, manpage:) }

  let(:manpage) { nil }

  describe '.parse' do
    [
      [
        'ls',
        [
          {
            type: :command_name,
            text: 'ls'
          }
        ]
      ],
      [
        'ls -l',
        [
          {
            type: :command_name,
            text: 'ls'
          },
          {
            type: :flag,
            text: '-l'
          }
        ]
      ],
      [
        'ls -lh',
        [
          {
            type: :command_name,
            text: 'ls'
          },
          {
            type: :flag,
            text: '-l'
          },
          {
            type: :flag,
            text: '-h'
          }
        ]
      ],
      [
        'ls -ltr',
        [
          {
            type: :command_name,
            text: 'ls'
          },
          {
            type: :flag,
            text: '-l'
          },
          {
            type: :flag,
            text: '-t'
          },
          {
            type: :flag,
            text: '-r'
          }
        ]
      ],
      [
        'ls --version',
        [
          {
            type: :command_name,
            text: 'ls'
          },
          {
            type: :flag,
            text: '--version'
          }
        ]
      ],
      [
        'ls /tmp',
        [
          {
            type: :command_name,
            text: 'ls'
          },
          {
            type: :unknown,
            text: '/tmp'
          }
        ]
      ],
      [
        'ls -ld /tmp',
        [
          {
            type: :command_name,
            text: 'ls'
          },
          {
            type: :flag,
            text: '-l'
          },
          {
            type: :flag,
            text: '-d'
          },
          {
            type: :unknown,
            text: '/tmp'
          }
        ]
      ],
      [
        'ls --color=auto',
        [
          {
            type: :command_name,
            text: 'ls'
          },
          {
            type: :flag,
            text: '--color',
            value: 'auto'
          }
        ]
      ],
      [
        'git add --patch test.txt',
        [
          {
            type: :command_name,
            text: 'git'
          },
          {
            type: :command_name,
            text: 'add'
          },
          {
            type: :flag,
            text: '--patch'
          },
          {
            type: :unknown,
            text: 'test.txt'
          }
        ]
      ],
      [
        'git checkout -b my-branch',
        [
          {
            type: :command_name,
            text: 'git'
          },
          {
            type: :command_name,
            text: 'checkout'
          },
          {
            type: :flag,
            text: '-b'
          },
          {
            type: :unknown,
            text: 'my-branch'
          }
        ]
      ]
    ].each do |string, expected|
      context string do
        it 'parses as expected' do
          parsed = described_class.parse(string)
          expect(parsed.tokens).to eq(expected.map do |expected_token|
            Command::Token.new(**expected_token)
          end)
        end
      end
    end

    context 'when flag takes argument, but no manpage is provided' do
      let(:cmd) { 'docker build -t getting-started .' }
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
      let(:manpage) { ManpageDirectory.get_manpage('docker-build') }
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
              type: :unknown,
              text: '.'
            )
          ]
        )
      end
    end

    context 'when documented single-dash flag has multi-character name' do
      let(:cmd) { 'find . -type f -print0' }
      let(:manpage) { ManpageDirectory.get_manpage('find') }
      it 'interprets flag correclty' do
        expect(subject.tokens).to eq(
          [
            Command::Token.new(
              type: :command_name,
              text: 'find'
            ),
            Command::Token.new(
              type: :unknown,
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
  end
end
