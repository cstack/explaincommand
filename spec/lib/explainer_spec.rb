require 'rails_helper'

describe Explainer do
  describe '.explain' do
    subject { described_class.explain(command) }

    context 'basic command' do
      let(:command) { 'ls -ltr /tmp' }
      it 'explains the command' do
        expect(subject).to be_a(Explanation)
        expect(subject.command_name).to eq('ls')
        expect(subject.annotations).to eq(
          [
            [
              '-l',
              "-l (The lowercase letter\nâellâ.) List files in the long format, as \ndescribed in the The Long Format subsection below."
            ],
            [
              '-t',
              "-t Sort by descending time\nmodified (most recently modified first). \nIf two files have the same modification timestamp, sort\ntheir \nnames in ascending lexicographical order. The -r option\nreverses \nboth of these sort orders."
            ],
            [
              '-r',
              "-r Reverse the order of the\nsort."
            ]
          ]
        )
      end
    end

    context 'with a subcommand' do
      let(:command) { 'git add test.txt' }
      it 'identifies the manpage for the subcommand' do
        expect(subject.command_name).to eq('git-add')
      end
    end

    context 'when the manpage has multiple flags per paragraph' do
      let(:command) { 'git --help' }
      it 'correctly annoates the flags' do
        expect(subject.annotations).to eq(
          [
            [
              '--help',
              "-h, --help \nPrints the synopsis and a list of the most commonly used\ncommands. \nIf the option --all or -a is given then all available\ncommands are \nprinted. If a Git command is named this option will bring up\nthe \nmanual page for that command."
            ]
          ]
        )
      end
    end
  end
end
