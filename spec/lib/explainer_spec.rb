require 'rails_helper'

describe Explainer do
  describe '.explain' do
    subject { described_class.explain(cmd) }

    context 'basic command' do
      let(:cmd) { 'ls -ltr /tmp' }

      it 'explains the command' do
        expect(subject.annotations).to eq(
          [
            Annotation.new(
              referenced_text: 'ls',
              text: 'list directory contents',
              token_ids: [0]
            ),
            Annotation.new(
              referenced_text: '-l',
              text: "-l (The lowercase letter\nâellâ.) List files in the long format, as \ndescribed in the The Long Format subsection below.",
              token_ids: [1]
            ),
            Annotation.new(
              referenced_text: '-t',
              text: "-t Sort by descending time\nmodified (most recently modified first). \nIf two files have the same modification timestamp, sort\ntheir \nnames in ascending lexicographical order. The -r option\nreverses \nboth of these sort orders.",
              token_ids: [2]
            ),
            Annotation.new(
              referenced_text: '-r',
              text: "-r Reverse the order of the\nsort.",
              token_ids: [3]
            ),
            Annotation.new(
              referenced_text: '/tmp',
              text: '[file ...]',
              token_ids: [4]
            )
          ]
        )
      end
    end

    context 'with a subcommand' do
      let(:cmd) { 'git add test.txt' }

      it 'identifies the manpage for the subcommand' do
        expect(subject.annotations.map(&:referenced_text)).to eq(
          [
            'git add',
            'test.txt'
          ]
        )
      end
    end

    context 'with positional arguments' do
      let(:cmd) { 'chmod 600 id_rsa_gh_deploy' }

      it 'explains the command' do
        expect(subject.annotations).to eq(
          [
            Annotation.new(
              referenced_text: 'chmod',
              text: 'change file modes or Access Control Lists',
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
