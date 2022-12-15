require 'rails_helper'

describe FlagParser do
  describe '.parse_flag_definition' do
    subject { described_class.parse_flag_definition(text) }

    context 'when flag has two aliases and an argument' do
      let(:text) { '-m, --magic-file magicfiles' }

      it 'parses out both aliases and the argument' do
        expect(subject).to eq(
          [
            {
              aliases: ['-m', '--magic-file'],
              argument_type: :SEPARATED_BY_SPACE
            }
          ]
        )
      end
    end

    context 'when flag has two aliases and an argument using an equal sign' do
      let(:text) { '-c, --bytes=[-]NUM' }

      it 'parses out both aliases and the argument' do
        expect(subject).to eq(
          [
            {
              aliases: ['-c'],
              argument_type: Flag::ArgumentType::SEPARATED_BY_SPACE
            },
            {
              aliases: ['--bytes'],
              argument_type: Flag::ArgumentType::SEPARATED_BY_EQUAL_SIGN
            }
          ]
        )
      end
    end

    context 'when flag takes a parameter using equal sign' do
      let(:text) { '--reference=RFILE' }

      it 'parses out both aliases and the argument' do
        expect(subject).to eq([
                                {
                                  aliases: ['--reference'],
                                  argument_type: :SEPARATED_BY_EQUAL_SIGN
                                }
                              ])
      end
    end

    context 'when flag has two aliases and a name value pair' do
      let(:text) { '-P, --parameter name=value' }

      it 'parses out both aliases and the argument' do
        expect(subject).to eq([
                                {
                                  aliases: ['-P', '--parameter'],
                                  argument_type: :SEPARATED_BY_SPACE
                                }
                              ])
      end
    end

    context 'when flag takes an optional argument' do
      let(:text) { '--color[=WHEN], --colour[=WHEN]' }

      it 'parses out both aliases and the argument' do
        expect(subject).to eq([
                                {
                                  aliases: ['--color', '--colour'],
                                  argument_type: :OPTIONAL_SEPARATED_BY_EQUAL_SIGN
                                }
                              ])
      end
    end

    context 'when flag takes argument with or without equal depending on alias' do
      let(:text) { '-e script, --expression=script' }

      it 'parses out both forms' do
        expect(subject).to eq(
          [
            {
              aliases: ['-e'],
              argument_type: Flag::ArgumentType::SEPARATED_BY_SPACE
            },
            {
              aliases: ['--expression'],
              argument_type: Flag::ArgumentType::SEPARATED_BY_EQUAL_SIGN
            }
          ]
        )
      end
    end
  end
end
