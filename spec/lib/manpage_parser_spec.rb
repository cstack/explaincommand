require 'rails_helper'

describe ManpageParser do
  describe '.parse_html_string' do
    Dir['./data/manpages/*'].each do |path|
      filename = path.split('/').last
      command = filename.split('.').first
      context filename do
        it 'parses as expected' do
          html_string = File.read(path)
          manpage = described_class.parse_html_string(html_string)
          fixture_path = "./spec/fixtures/manpages/#{command}.json"
          # File.write(fixture_path, JSON.pretty_generate(manpage))
          expected = Manpage.from_json(File.read(fixture_path))
          expect(manpage).to eq(expected)
        end
      end
    end
  end

  describe '.parse_helppage_string' do
    Dir['./data/helppages/*'].each do |path|
      filename = path.split('/').last
      command = filename.split('.').first
      context filename do
        it 'parses as expected' do
          helppage_string = File.read(path)
          manpage = described_class.parse_helppage_string(helppage_string)
          fixture_path = "./spec/fixtures/manpages/#{command}.json"
          # File.write(fixture_path, JSON.pretty_generate(manpage))
          expected = Manpage.from_json(File.read(fixture_path))
          expect(manpage).to eq(expected)
        end
      end
    end
  end

  describe 'extract_flags' do
    subject { described_class.send(:extract_flags, text) }

    context 'does not start with a flag' do
      let(:text) { 'this is just some text with a --flag near the end' }
      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end

    context 'starts with a short flag' do
      let(:text) { '-f is a flag' }
      it 'extracts the flag' do
        expect(subject.aliases).to eq(['-f'])
        expect(subject.takes_argument).to eq(false)
      end
    end

    context 'starts with a long flag' do
      let(:text) { '--flag is a flag' }
      it 'extracts the flag' do
        expect(subject.aliases).to eq(['--flag'])
        expect(subject.takes_argument).to eq(false)
      end
    end

    context 'starts with both a short and long flag' do
      let(:text) { '-f, --flag are both flags' }
      it 'extracts the flags' do
        expect(subject.aliases).to eq(['-f', '--flag'])
        expect(subject.takes_argument).to eq(false)
      end
    end

    context 'starts with flags, then mentions another flag in the description' do
      let(:text) { '-f, --flag is a flag that is similar to --other-flag' }
      it 'only extracts the flags at the beginning' do
        expect(subject.aliases).to eq(['-f', '--flag'])
        expect(subject.takes_argument).to eq(false)
      end
    end

    context 'has a multi-word flag' do
      let(:text) { '--multi-word-flag is treated as a single flag' }
      it 'only extracts the flags at the beginning' do
        expect(subject.aliases).to eq(['--multi-word-flag'])
        expect(subject.takes_argument).to eq(false)
      end
    end

    context 'takes an argument' do
      let(:text) { "  -f, --file string             Name of the Dockerfile (Default is 'PATH/Dockerfile')" }
      it 'recognizes the argument' do
        expect(subject.aliases).to eq(['-f', '--file'])
        expect(subject.takes_argument).to eq(true)
      end
    end
  end
end
