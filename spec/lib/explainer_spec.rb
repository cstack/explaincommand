require 'rails_helper'

describe Explainer do
  describe '.explain' do
    subject { described_class.explain(command) }

    context 'basic command' do
      let(:command) { 'ls -ltr /tmp' }
      it 'explains the command' do
        expect(subject).to be_a(Explanation)
        expect(subject.command).to eq('ls')
        expect(subject.annotations).to eq(
          [
            ['-l',
             '(The lowercase letter âellâ.) List files in the long format, as  described in the The Long Format subsection below.'],
            ['-t',
             'Sort by descending time modified (most recently modified first).  If two files have the same modification timestamp, sort their  names in ascending lexicographical order. The -r option reverses  both of these sort orders.'],
            ['-r', 'Reverse the order of the sort.']
          ]
        )
      end
    end

    context 'with a subcommand' do
      let(:command) { 'git add test.txt' }
      it 'identifies the manpage for the subcommand' do
        expect(subject.command).to eq('git-add')
      end
    end
  end
end
