require 'rails_helper'

describe Explanation do
  describe '.from_manpage' do
    subject { described_class.from_manpage(manpage:, command:) }

    context 'docker build command' do
      let(:command) { CommandParser.parse('docker build -t getting-started .', manpage:) }
      let(:manpage) { ManpageDirectory.get_manpage('docker-build') }
      it 'explains the command' do
        expect(subject.command_name).to eq('docker-build')
        expect(subject.command_description).to eq('Build an image from a Dockerfile')
        expect(subject.annotations).to eq(
          [
            Annotation.new(
              referenced_text: 'docker-build',
              text: 'Build an image from a Dockerfile'
            ),
            Annotation.new(
              referenced_text: '-t getting-started',
              text: "  -t, --tag list                Name and optionally a tag in the 'name:tag' format"
            )
          ]
        )
      end
    end
  end
end
