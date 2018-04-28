class WelcomeController < ApplicationController
  def index
    redirect_to hostname_url
  end
end
