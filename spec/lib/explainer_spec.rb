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
              text: 'FILE',
              token_ids: [4]
            )
          ]
        )
      end
    end

    context 'homepage example command for chmod' do
      let(:cmd) { 'chmod 600 id_rsa_gh_deploy' }

      it 'explains the command' do
        expect(subject.annotations).to eq(
          [
            Annotation.new(
              referenced_text: 'chmod',
              text: 'change file mode bits',
              token_ids: [0]
            ),
            Annotation.new(
              referenced_text: '600',
              text: 'MODE',
              token_ids: [1]
            ),
            Annotation.new(
              referenced_text: 'id_rsa_gh_deploy',
              text: 'FILE',
              token_ids: [2]
            )
          ]
        )
      end
    end

    context 'homepage example command for docker build' do
      let(:cmd) { 'docker build -t getting-started .' }

      it 'explains the command' do
        expect(subject.annotations).to eq(
          [
            Annotation.new(
              referenced_text: 'docker build',
              text: 'Build an image from a Dockerfile',
              token_ids: [0, 1]
            ),
            Annotation.new(
              referenced_text: '-t getting-started',
              text: 'Repository names (and optionally with tags) to be applied to the resulting image in case of success. Refer to docker-tag(1) for more information about valid tag names.',
              token_ids: [2]
            ),
            Annotation.new(
              referenced_text: '.',
              text: 'Experimental',
              token_ids: [3]
            )
          ]
        )
      end
    end
  end
end
