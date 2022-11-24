require 'rails_helper'

describe FlagParser do
  describe '.extract_flags_from_dl_in_description_section' do
    subject { described_class.extract_flags_from_dl_in_description_section(html) }

    let(:html) { Nokogiri::HTML(File.read('spec/fixtures/html_manpages/ls.html')) }

    it 'parses flags from ls' do
      expect(subject.length).to eq(59)
    end
  end

  describe '.extract_flags_from_alternating_p_and_div_in_options_section' do
    subject { described_class.extract_flags_from_alternating_p_and_div_in_options_section(html) }

    let(:html) { Nokogiri::HTML(File.read('spec/fixtures/html_manpages/git-add.html')) }

    it 'parses flags from git-add' do
      expect(subject.length).to eq(20)
    end
  end
end
