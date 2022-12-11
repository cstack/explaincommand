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
              text: 'Repository names (and optionally with tags) to be applied to the resulting image in case of ' \
                    'success. Refer to docker-tag(1) for more information about valid tag names.',
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
              text: '(HTTP SMTP IMAP) For HTTP protocol family, this lets curl emulate a filled-in form in which a ' \
                    'user has pressed the submit button. This causes curl to POST data using the Content-Type ' \
                    'multipart/form-data according to RFC 2388. For SMTP and IMAP protocols, this is the means to ' \
                    'compose a multipart mail message to transmit. ',
              token_ids: [1]
            ),
            Annotation.new(
              referenced_text: '-F secret=@file.txt',
              text: '(HTTP SMTP IMAP) For HTTP protocol family, this lets curl emulate a filled-in form in which a ' \
                    'user has pressed the submit button. This causes curl to POST data using the Content-Type ' \
                    'multipart/form-data according to RFC 2388. For SMTP and IMAP protocols, this is the means to ' \
                    'compose a multipart mail message to transmit. ',
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

    context 'homepage example command for wget' do
      let(:cmd) { 'wget -r -l 1 -H -t 1 -nd -N -np -A mp3 -e robots=off http://example.com' }

      it 'explains the command' do
        expect(subject.annotations).to eq(
          [
            Annotation.new(
              referenced_text: 'wget',
              text: 'The non-interactive network downloader.',
              token_ids: [0]
            ),
            Annotation.new(
              referenced_text: '-r',
              text: 'Turn on recursive retrieving. The default maximum depth is 5.',
              token_ids: [1]
            ),
            Annotation.new(
              referenced_text: '-l 1',
              text: 'Set the maximum number of subdirectories that Wget will recurse into to depth . ' \
                    'In order to prevent one from accidentally downloading very large websites when using recursion ' \
                    'this is limited to a depth of 5 by default, i.e., it will traverse at most 5 directories deep ' \
                    'starting from the provided URL. Set -l 0 or -l inf for infinite recursion depth.   ' \
                    'wget -r -l 0 http://<site>/1.html ',
              token_ids: [2]
            ),
            Annotation.new(
              referenced_text: '-H',
              text: 'Enable spanning across hosts when doing recursive retrieving.',
              token_ids: [3]
            ),
            Annotation.new(
              referenced_text: '-t 1',
              text: 'Set number of tries to number . Specify 0 or inf for infinite retrying. The default is to retry ' \
                    '20 times, with the exception of fatal errors like "connection refused" or "not found" (404), ' \
                    'which are not retried.',
              token_ids: [4]
            ),
            Annotation.new(
              referenced_text: '-nd',
              text: 'Do not create a hierarchy of directories when retrieving recursively. ' \
                    'With this option turned on, all files will get saved to the current directory, ' \
                    'without clobbering (if a name shows up more than once, the filenames will get extensions .n ).',
              token_ids: [5]
            ),
            Annotation.new(
              referenced_text: '-N',
              text: 'Turn on time-stamping.',
              token_ids: [6]
            ),
            Annotation.new(
              referenced_text: '-np',
              text: 'Do not ever ascend to the parent directory when retrieving recursively. ' \
                    'This is a useful option, since it guarantees that only the files below a certain hierarchy will ' \
                    'be downloaded.',
              token_ids: [7]
            ),
            Annotation.new(
              referenced_text: '-A mp3',
              text: 'Specify comma-separated lists of file name suffixes or patterns to accept or reject. ' \
                    'Note that if any of the wildcard characters, * , ? , [ or ] , appear in an element of acclist ' \
                    'or rejlist , it will be treated as a pattern, rather than a suffix. In this case, you have to ' \
                    'enclose the pattern into quotes to prevent your shell from expanding it, like in -A "*.mp3" ' \
                    "or -A '*.mp3' .",
              token_ids: [8]
            ),
            Annotation.new(
              referenced_text: '-e robots=off',
              text: 'Execute command as if it were a part of .wgetrc . ' \
                    'A command thus invoked will be executed after the commands in .wgetrc , ' \
                    'thus taking precedence over them. If you need to specify more than one wgetrc command, ' \
                    'use multiple instances of -e .',
              token_ids: [9]
            ),
            Annotation.new(
              referenced_text: 'http://example.com',
              text: 'URL',
              token_ids: [10]
            )
          ]
        )
      end
    end
  end
end
