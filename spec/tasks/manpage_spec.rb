require 'rails_helper'
Rails.application.load_tasks

# rubocop:disable RSpec/DescribeClass
describe 'manpage.rake' do
  # rubocop:enable RSpec/DescribeClass
  describe 'parse' do
    subject { Rake::Task['manpage:parse'].invoke(filepath, main_command, subcommand) }

    context 'for a manpage with no subcommand' do
      let(:filepath) { './spec/fixtures/html_manpages/chmod.html' }
      let(:main_command) { 'chmod' }
      let(:subcommand) { nil }

      it 'does not error' do
        expect { subject }.not_to raise_error
      end
    end

    context 'for a manpage with a subcommand' do
      let(:filepath) { './spec/fixtures/html_manpages/git-add.html' }
      let(:main_command) { 'git' }
      let(:subcommand) { 'add' }

      it 'does not error' do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe 'parse_helppage' do
    subject { Rake::Task['manpage:parse_helppage'].invoke(filepath, main_command, subcommand) }

    context 'for a helppage with a subcommand' do
      let(:filepath) { './spec/fixtures/helppages/docker-attach.txt' }
      let(:main_command) { 'docker' }
      let(:subcommand) { 'attach' }

      it 'does not error' do
        expect { subject }.not_to raise_error
      end
    end
  end
end
