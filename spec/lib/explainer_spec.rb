require 'rails_helper'

describe Explainer do
  describe '.explain' do
    subject { described_class.explain(command) }

    context 'basic command' do
      let(:command) { 'ls -ltr /tmp' }
      it 'explains the command' do
        expect(subject).to be_a(Explanation)
        expect(subject.command_name).to eq('ls')
        expect(subject.annotations.map(&:aliases)).to eq(
          [
            ['-l'],
            ['-t'],
            ['-r']
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
        expect(subject.annotations.map(&:aliases)).to eq(
          [
            ['-h', '--help']
          ]
        )
      end
    end
  end
end
