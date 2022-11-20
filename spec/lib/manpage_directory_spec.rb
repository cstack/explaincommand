require 'rails_helper'

describe ManpageDirectory do
  describe '.exists?' do
    subject { described_class.exists?(command_name) }

    context 'when manpage exists' do
      let(:command_name) { Command::Name.new('ls') }

      it 'is true' do
        expect(subject).to be(true)
      end
    end

    context 'when manpage does not exist' do
      let(:command_name) { Command::Name.new('does-not-exist') }

      it 'is false' do
        expect(subject).to be(false)
      end
    end

    context 'when manpage for subcommand exists' do
      let(:command_name) { Command::Name.new('git', 'add') }

      it 'is true' do
        expect(subject).to be(true)
      end
    end
  end
end
