class ExplainController < ApplicationController
  def index
    @examples = [
      'ls -ltr /tmp',
      'find . -type f -print0',
      'docker build -t getting-started .',
      'chmod 600 id_rsa_gh_deploy'
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
