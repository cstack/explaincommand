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
          # File.write(fixture_path, manpage.to_json)
          expected = Manpage.from_json(File.read(fixture_path))
          expect(manpage).to eq(expected)
        end
      end
    end
  end
end
