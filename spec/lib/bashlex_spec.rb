require 'rails_helper'

describe Bashlex do
  subject { described_class.parse(string) }
  context 'two simple commands joined by an operator' do
    let(:string) { 'true && false' }
    xit 'parses correctly' do
      expect(subject).to eq(
        {
          'parts' => [
            {
              'kind' => 'list',
              'parts' => [
                {
                  'kind' => 'command',
                  'parts' => [
                    {
                      'kind' => 'word',
                      'parts' => [],
                      'pos' => [0, 4]
                    }
                  ],
                  'pos' => [0, 4]
                },
                {
                  'kind' => 'operator',
                  'pos' => [5, 7]
                },
                {
                  'kind' => 'command',
                  'parts' => [
                    {
                      'kind' => 'word',
                      'parts' => [],
                      'pos' => [8, 13]
                    }
                  ],
                  'pos' => [8, 13]
                }
              ],
              'pos' => [0, 13]
            }
          ]
        }
      )
    end
  end
end
