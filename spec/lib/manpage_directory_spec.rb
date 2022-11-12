require 'rails_helper'

describe ManpageDirectory do
  describe '.get_manpage' do
    Dir['./data/manpages/*'].each do |path|
      filename = path.split('/').last
      command = filename.split('.').first
      context filename do
        it 'parses as expected' do
          manpage = described_class.get_manpage(command)
          fixture_path = "./spec/fixtures/manpages/#{command}.json"
          # File.write(fixture_path, manpage.to_json)
          expected = Manpage.from_json(File.read(fixture_path))
          expect(manpage).to eq(expected)
        end
      end
    end
  end
end
