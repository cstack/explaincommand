class ExplainController < ApplicationController
  def index
    @examples = [
      'ls -ltr /tmp',
      'chmod 600 id_rsa_gh_deploy',
      'docker build -t getting-started .',
      'curl -F person=anonymous -F secret=@file.txt http://example.com/submit.cgi'
    ]
  end

  def show
    @cmd = params['cmd']
    @explanation = Explainer.explain(@cmd)
    respond_to do |format|
      format.html
      format.json { render json: @explanation }
    end
  end
end
