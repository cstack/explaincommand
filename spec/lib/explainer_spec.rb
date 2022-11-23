require 'rails_helper'

describe Explainer do
  describe '.explain' do
    subject { described_class.explain(cmd) }

    context 'homepage example command for ls' do
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
              text: 'use a long listing format',
              token_ids: [1]
            ),
            Annotation.new(
              referenced_text: '-t',
              text: 'sort by time, newest first; see --time',
              token_ids: [2]
            ),
            Annotation.new(
              referenced_text: '-r',
              text: 'reverse order while sorting',
              token_ids: [3]
            ),
            Annotation.new(
              referenced_text: '/tmp',
              text: '[FILE]...',
              token_ids: [4]
            )
          ]
        )
      end
    end
  end
end
