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
          File.write(fixture_path, JSON.pretty_generate(manpage))
          expected = Manpage.from_json(File.read(fixture_path))
          expect(manpage).to eq(expected)
        end
      end
    end
  end

  describe 'extract_flags' do
    subject { described_class.send(:extract_flags, text) }

    context 'starts with a short flag' do
      let(:text) { '-f is a flag' }
      it 'extracts the flag' do
        expect(subject).to eq(['-f'])
      end
    end

    context 'starts with a long flag' do
      let(:text) { '--flag is a flag' }
      it 'extracts the flag' do
        expect(subject).to eq(['--flag'])
      end
    end

    context 'starts with both a short and long flag' do
      let(:text) { '-f, --flag are both flags' }
      it 'extracts the flags' do
        expect(subject).to eq(['-f', '--flag'])
      end
    end

    context 'starts with flags, then mentions another flag in the description' do
      let(:text) { '-f, --flag is a flag that is similar to --other-flag' }
      it 'only extracts the flags at the beginning' do
        expect(subject).to eq(['-f', '--flag'])
      end
    end
  end
end
