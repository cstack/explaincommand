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
              text: 'PATH | URL | -',
              token_ids: [3]
            )
          ]
        )
      end
    end

    context 'homepage example command for curl' do
      let(:cmd) { 'curl -F person=anonymous -F secret=@file.txt http://example.com/submit.cgi' }

      it 'explains the command' do
        expect(subject.annotations).to eq(
          [
            Annotation.new(
              referenced_text: 'curl',
              text: 'transfer a URL',
              token_ids: [0]
            ),
            Annotation.new(
              referenced_text: '-F person=anonymous',
              text: '(HTTP SMTP IMAP) For HTTP protocol family, this lets curl emulate a filled-in form in which a user has pressed the submit button. This causes curl to POST data using the Content-Type multipart/form-data according to RFC 2388. For SMTP and IMAP protocols, this is the means to compose a multipart mail message to transmit. ',
              token_ids: [1]
            ),
            Annotation.new(
              referenced_text: '-F secret=@file.txt',
              text: '(HTTP SMTP IMAP) For HTTP protocol family, this lets curl emulate a filled-in form in which a user has pressed the submit button. This causes curl to POST data using the Content-Type multipart/form-data according to RFC 2388. For SMTP and IMAP protocols, this is the means to compose a multipart mail message to transmit. ',
              token_ids: [2]
            ),
            Annotation.new(
              referenced_text: 'http://example.com/submit.cgi',
              text: '[options / URLs]',
              token_ids: [3]
            )
          ]
        )
      end
    end
  end
end
