require 'rails_helper'

describe ManpageDirectory do
  describe '.exists?' do
    subject { described_class.exists?(command_name:, subcommand:) }

    context 'when manpage exists' do
      let(:command_name) { 'ls' }
      let(:subcommand) { nil }

      it 'is true' do
        expect(subject).to eq(true)
      end
    end

    context 'when manpage does not exist' do
      let(:command_name) { 'does-not-exist' }
      let(:subcommand) { nil }

      it 'is false' do
        expect(subject).to eq(false)
      end
    end

    context 'when manpage for subcommand exists' do
      let(:command_name) { 'git' }
      let(:subcommand) { 'add' }

      it 'is false' do
        expect(subject).to eq(true)
      end
    end
  end
end
