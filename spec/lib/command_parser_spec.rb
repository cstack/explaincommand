require 'rails_helper'

describe CommandParser do
  subject { described_class.parse(cmd, manpage:) }
  let(:manpage) { nil }

  describe '.parse' do
    [
      [
        'ls',
        {
          "name": 'ls',
          "flags": [],
          "arguments": []
        }
      ],
      [
        'ls -l',
        {
          "name": 'ls',
          "flags": ['-l'],
          "arguments": []
        }
      ],
      [
        'ls -lh',
        {
          "name": 'ls',
          "flags": ['-l', '-h'],
          "arguments": []
        }
      ],
      [
        'ls -ltr',
        {
          "name": 'ls',
          "flags": ['-l', '-t', '-r'],
          "arguments": []
        }
      ],
      [
        'ls --version',
        {
          "name": 'ls',
          "flags": ['--version'],
          "arguments": []
        }
      ],
      [
        'ls /tmp',
        {
          "name": 'ls',
          "flags": [],
          "arguments": ['/tmp']
        }
      ],
      [
        'ls -ld /tmp',
        {
          "name": 'ls',
          "flags": ['-l', '-d'],
          "arguments": ['/tmp']
        }
      ],
      [
        'ls --color=auto',
        {
          "name": 'ls',
          "flags": [['--color', 'auto']],
          "arguments": []
        }
      ],
      [
        'git add --patch test.txt',
        {
          "name": 'git-add',
          "flags": ['--patch'],
          "arguments": ['test.txt']
        }
      ],
      [
        'docker build -t getting-started .',
        {
          "name": 'docker-build',
          "flags": ['-t'],
          "arguments": ['getting-started', '.']
        }
      ],
      [
        'git checkout -b my-branch',
        {
          "name": 'git-checkout',
          "flags": ['-b'],
          "arguments": ['my-branch']
        }
      ]
    ].each do |string, expected|
      context string do
        it 'parses as expected' do
          parsed = described_class.parse(string)
          expect(parsed.name).to eq(expected[:name])
          expect(parsed.flags).to eq(expected[:flags])
          expect(parsed.arguments).to eq(expected[:arguments])
        end
      end
    end

    context 'when flag takes argument' do
      let(:cmd) { 'docker build -t getting-started .' }
      let(:manpage) { ManpageDirectory.get_manpage('docker-build') }
      it 'binds argument to flag' do
        expect(subject.flags).to eq([['-t', 'getting-started']])
      end
    end
  end
end
