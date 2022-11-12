require 'rails_helper'

RSpec.describe '/explain', type: :request do
  context 'viewing the page' do
    it 'displays the explanation for a command' do
      get '/explain', params: { cmd: 'ls -ltr' }

      expect(response.body).to include('ls')
      expect(response.body).to include('list directory contents')
      expect(response.body).to include('-l')
      expect(response.body).to include('List files in the long format')
    end
  end

  context 'requesting json' do
    it 'returns the json representation of the annotated command' do
      get '/explain', params: { cmd: 'ls -ltr' }, headers: { 'ACCEPT' => 'application/json' }

      fixture_path = './spec/fixtures/api_responses/ls-response.json'
      # File.write(fixture_path, JSON.pretty_generate(JSON.parse(response.body)))
      expect(JSON.parse(response.body)).to eq(JSON.parse(File.read(fixture_path)))
    end
  end
end
