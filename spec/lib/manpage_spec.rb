require 'rails_helper'

describe Manpage do
  describe '.for_command' do
    Dir['./data/manpages/*'].each do |path|
      filename = path.split('/').last
      command = filename.split('.').first
      context filename do
        it 'parses as expected' do
          parsed = described_class.for_command(command).transform_keys(&:to_s)
          fixture_path = "./spec/fixtures/manpages/#{command}.json"
          # File.write(fixture_path, JSON.pretty_generate(parsed))
          expected = JSON.parse(File.read(fixture_path))
          expect(parsed).to eq(expected)
        end
      end
    end
  end
end
