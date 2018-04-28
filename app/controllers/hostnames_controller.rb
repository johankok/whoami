class HostnamesController < ApplicationController
  def show
    @hostname = Socket.gethostname

    respond_to do |format|
      format.html
      format.json { render json: { hostname: @hostname } }
    end
  end
end
