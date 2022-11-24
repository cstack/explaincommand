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
end
