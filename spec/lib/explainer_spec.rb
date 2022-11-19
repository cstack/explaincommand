require 'rails_helper'

describe Explainer do
  describe '.explain' do
    subject { described_class.explain(command) }

    context 'basic command' do
      let(:command) { 'ls -ltr /tmp' }

      it 'explains the command' do
        expect(subject.annotations.map(&:referenced_text)).to eq(
          [
            'ls',
            '-l',
            '-t',
            '-r',
            '/tmp'
          ]
        )
      end
    end

    context 'with a subcommand' do
      let(:command) { 'git add test.txt' }

      it 'identifies the manpage for the subcommand' do
        expect(subject.annotations.map(&:referenced_text)).to eq(
          [
            'git add',
            'test.txt'
          ]
        )
      end
    end
  end
end
