require 'rails_helper'

describe ManpageDirectory do
  describe '.manpage_exists?' do
    subject { described_class.manpage_exists?(command) }

    context 'when manpage exists' do
      let(:command) { 'ls' }

      it 'is true' do
        expect(subject).to eq(true)
      end
    end

    context 'when manpage does not exist' do
      let(:command) { 'does-not-exist' }

      it 'is false' do
        expect(subject).to eq(false)
      end
    end
  end
end
