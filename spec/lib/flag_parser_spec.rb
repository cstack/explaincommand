require 'rails_helper'

describe FlagParser do
  describe '.identify_format' do
    it 'identifies right format for each command' do
      [
        ['ls', FlagParser::Format1],
        ['git-add', FlagParser::Format2],
        ['git-checkout', FlagParser::Format2],
        ['docker-build', FlagParser::Format3],
        ['chmod', FlagParser::Format4]
      ].each do |row|
        command_name = row[0]
        html = Nokogiri::HTML(File.read("spec/fixtures/html_manpages/#{command_name}.html"))
        expect([command_name, described_class.identify_format(html)]).to eq(row)
      end
    end
  end

  describe '.parse_flag_definition' do
    subject { described_class.parse_flag_definition(text) }

    context 'when flag has two aliases and an argument' do
      let(:text) { '-m, --magic-file magicfiles' }

      it 'parses out both aliases and the argument' do
        expect(subject).to eq({
                                aliases: ['-m', '--magic-file'],
                                takes_argument: true
                              })
      end
    end

    context 'when flag has two aliases and a name value pair' do
      let(:text) { '-P, --parameter name=value' }

      it 'parses out both aliases and the argument' do
        expect(subject).to eq({
                                aliases: ['-P', '--parameter'],
                                takes_argument: true
                              })
      end
    end

    context 'when flag takes a parameter using equal sign' do
      let(:text) { '--reference=RFILE' }

      it 'treats the whole thing as a flag without an argument' do
        expect(subject).to eq({
                                aliases: ['--reference=RFILE'],
                                takes_argument: false
                              })
      end
    end
  end
end
