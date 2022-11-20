require 'rails_helper'

describe Explanation do
  describe '.from_manpage' do
    subject { described_class.from_manpage(manpage:, command:) }

    context 'docker build command' do
      let(:command) { CommandParser.parse('docker build -t getting-started .', manpage:) }
      let(:manpage) { ManpageDirectory.get_manpage(command_name: 'docker', subcommand: 'build') }

      it 'explains the command' do
        expect(subject.command_description).to eq('Build an image from a Dockerfile')
        expect(subject.annotations).to eq(
          [
            Annotation.new(
              referenced_text: 'docker build',
              text: 'Build an image from a Dockerfile',
              token_ids: [0, 1]
            ),
            Annotation.new(
              referenced_text: '-t getting-started',
              text: "  -t, --tag list                Name and optionally a tag in the 'name:tag' format",
              token_ids: [2]
            ),
            Annotation.new(
              referenced_text: '.',
              text: 'PATH',
              token_ids: [3]
            )
          ]
        )
      end
    end

    context 'with positional arguments' do
      let(:command) { CommandParser.parse('chmod 600 id_rsa_gh_deploy', manpage:) }
      let(:manpage) { ManpageDirectory.get_manpage(command_name: 'chmod', subcommand: nil) }

      it 'explains the command' do
        expect(subject.annotations).to eq(
          [
            Annotation.new(
              referenced_text: 'chmod',
              text: 'chmod â change file modes or Access Control Lists',
              token_ids: [0]
            ),
            Annotation.new(
              referenced_text: '600',
              text: 'mode',
              token_ids: [1]
            ),
            Annotation.new(
              referenced_text: 'id_rsa_gh_deploy',
              text: 'file',
              token_ids: [2]
            )
          ]
        )
      end
    end
  end
end
