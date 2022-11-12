require 'rails_helper'

describe Explainer do
  describe '.explain' do
    context 'ls -ltr /tmp' do
      it 'explains the command' do
        explanation = described_class.explain('ls -ltr /tmp')
        expect(explanation).to be_a(Explanation)
        expect(explanation.command).to eq('ls')
        expect(explanation.annotations).to eq([
                                                ['-l',
                                                 '(The lowercase letter âellâ.) List files in the long format, as  described in the The Long Format subsection below.'],
                                                ['-t',
                                                 'Sort by descending time modified (most recently modified first).  If two files have the same modification timestamp, sort their  names in ascending lexicographical order. The -r option reverses  both of these sort orders.'],
                                                ['-r', 'Reverse the order of the sort.']
                                              ])
      end
    end
  end
end
