class ExplainController < ActionController::Base
  def index
  end

  def show
    @cmd = params["cmd"]
    @explanation = Explainer.explain(@cmd)
    respond_to do |format|
      format.html
      format.json { render json: @explanation }
    end
  end
end
